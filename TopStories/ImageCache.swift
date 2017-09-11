//
//  ImageCache.swift
//  TopStories
//
//  Created by Sam Meadley on 21/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit

final class ImageCache {
    
    private let cache: NSCache<NSString, UIImage>
    private let fileManager: FileManager
    
    /**
     Initializes the ImageCache with dependent objects.
     
     ImageCache internally handles a dual cache; one in-memory and one on disk. This allows images to
     be persisted across launches to save network traffic. Files are stores in Library/Caches; a 
     system provided store which iOS automatically empties if it starts to run out of storage.
     
     We should also set a cache policy to routinely clean up old content, but that is out of 
     scope for this project.
     
     - parameter cache: The underlying NSCache instance or nil, if not supplied a new instance
                        will be used.
     - parameter fileManager:   The file manager to use to access the disk cache or nil. If not
                                supplied the defaultManager is used.
     */
    init(cache: NSCache<NSString, UIImage> = NSCache(), fileManager: FileManager = FileManager.default) {
        self.cache = cache
        self.fileManager = fileManager
    }
    
    /**
     Gets the cached image for the URL, or nil if not present.
     
     First checks for membership of in-memory cache, before hitting the disk cache. It is recommended
     that imageForURL(_:) be called from a background thread as the disk fetch can be slow.
     
     Images fetched from the disk cache are decompressed and added to the in-memory cache for fast 
     future retrieval.
     
     - returns: UIImage instance if image is in the cache or nil.
     */
    func imageForURL(_ url: String) -> UIImage? {
        
        if let image = cache.object(forKey: url as NSString) {
            return image
        }
        
        // Attempt to fetch from Library/Caches.
        guard let path = try? urlForCachedImageForKey(url).path else {
            return nil
        }
        
        if !fileManager.fileExists(atPath: path) {
            return nil
        }
        
        guard let data = fileManager.contents(atPath: path) else {
            return nil
        }
        
        guard let image = UIImage(data: data)?.decompress() else {
            return nil
        }
        
        setImage(image, forURL: url)
        return image
    }
    
    /**
     Adds an image to the cache.
     
     Adds UIImage instance to in-memory cache and disk cache. It is recommended that
     setImage(_:forURL:temporaryFileURL:) is called from a background queue, as disk IO can be slow.
     
     Copies the downloaded data to a temporary location (returned from NSURLSessionDownloadTask) to
     Library/Caches/{filename} - where the filename is the MD5 hash of the URL of the image resource.
     
     - parameter image: UIImage instance to add to the cache.
     - parameter URL: Web URL of the downloaded image- used to calculate the MD5 cache key.
     - parameter temporaryFileURL: URL on disk of the temporary file download.
     */
    func setImage(_ image: UIImage, forURL url: String, temporaryFileURL: URL? = nil) {
        
        cache.setObject(image, forKey: url as NSString)
        
        guard let sourceURL = temporaryFileURL else {
            return
        }
        
        do {
            let destinationURL = try urlForCachedImageForKey(url)
            try fileManager.moveItem(at: sourceURL, to: destinationURL)
            
        } catch {
            // TODO: Handle error
        }
    }

    /**
     The expected URL for the cached image on disk.
     
     The path of the cached image on disk- if the image is contained in the cache, then it will exist
     at this path. If the image is not cached to disk, the path will be empty.
     
     We build the cache path by simply taking the MD5 hash of the passed key.
     
     - parameter key: The key to use for the cache filename.
     
     - throws: ImageCacheError.CachesDirectoryNotFound if iOS is unable to locate Library/Caches.
     
     - returns: NSURL instance containing the path of the cached image on disk.
     */
    func urlForCachedImageForKey(_ key: String) throws -> URL {
        
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        guard let url = urls.last else {
            throw ImageCacheError.cachesDirectoryNotFound
        }
        
        return url.appendingPathComponent(key.MD5())
    }
    
}

// MARK:- Error Types

enum ImageCacheError: Error {
    case cachesDirectoryNotFound
}

// MARK: - String extension methods

extension String {
    
    /**
     Transforms the current value of this String instance to an MD5 hash.
     
     - returns: A new string containing the MD5 hash.
     */
    func MD5() -> String {
        
        let data = self.data(using: String.Encoding.utf8)!
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5((data as NSData).bytes, CC_LONG(data.count), &digest)
        let hexBytes = digest.map { String(format: "%02x", $0) }
        
        return hexBytes.joined(separator: "")
    }
    
}

// MARK: - UIImage extensions methods

extension UIImage {
    
    /**
     Decompresses the image data.
     
     Decompresses the data on this UIImage instance- the benefit being we can perform this from a 
     background queue and avoid on-the-fly decompression occuring at the point of setting the image
     value of the imageView.
     
     - returns: A new UIImage instance containing the decompressed image.
     */
    func decompress() -> UIImage? {
        
        let imageRef = self.cgImage
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue
        
        guard let context = CGContext(data: nil, width: (imageRef?.width)!, height: (imageRef?.height)!, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        let rect = CGRect(x: 0, y: 0, width: (imageRef?.width)!, height: (imageRef?.height)!)
        context.draw(imageRef!, in: rect)
        
        let decompressedImageRef = context.makeImage()
        return UIImage(cgImage: decompressedImageRef!)
    }
    
}
