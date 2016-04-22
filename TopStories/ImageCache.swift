//
//  ImageCache.swift
//  TopStories
//
//  Created by Sam Meadley on 21/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit

class ImageCache {
    
    private let cache: NSCache
    private let fileManager: NSFileManager
    
    init(cache: NSCache = NSCache(), fileManager: NSFileManager = NSFileManager.defaultManager()) {
        self.cache = cache
        self.fileManager = fileManager
    }
    
    func imageForURL(URL: String) -> UIImage? {
        
        if let image = cache.objectForKey(URL) as? UIImage {
            return image
        }
        
        // Attempt to fetch from Library/Caches.
        do {
            guard let path = try self.URLForCachedImageForKey(URL).path else {
                return nil
            }
            
            if !fileManager.fileExistsAtPath(path) {
                return nil
            }
            
            guard let data = fileManager.contentsAtPath(path) else {
                return nil
            }
            
            guard let image = UIImage(data: data)?.decompress() else {
                return nil
            }
            
            setImage(image, forURL: URL)
            return image
            
        } catch {
            return nil
        }
    }
    
    func setImage(image: UIImage, forURL URL: String, temporaryFileURL: NSURL? = nil) {
        
        cache.setObject(image, forKey: URL)
        
        guard let sourceURL = temporaryFileURL else {
            return
        }
        
        do {
            let destinationURL = try self.URLForCachedImageForKey(URL)
            try fileManager.moveItemAtURL(sourceURL, toURL: destinationURL)
            
        } catch {
            // TODO: Handle error
        }
    }
    
}

// MARK:- Private methods

private extension ImageCache {
    
    func URLForCachedImageForKey(key: String) throws -> NSURL {
        
        let URLs = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        guard let URL = URLs.last else {
            throw ImageCacheError.CachesDirectoryNotFound
        }
        
        return URL.URLByAppendingPathComponent(key.MD5())
    }
    
}

// MARK:- Error Types

enum ImageCacheError: ErrorType {
    case CachesDirectoryNotFound
}

// MARK: - String extension methods

extension String {
    
    func MD5() -> String {
        
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        let hexBytes = digest.map { String(format: "%02x", $0) }
        
        return hexBytes.joinWithSeparator("")
    }
    
}

// MARK: - UIImage extensions methods

extension UIImage {
    
    func decompress() -> UIImage? {
        
        let imageRef = self.CGImage
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue).rawValue
        
        guard let context = CGBitmapContextCreate(nil, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), 8, 0, colorSpace, bitmapInfo) else {
            return nil
        }
        
        let rect = CGRect(x: 0, y: 0, width: CGImageGetWidth(imageRef), height: CGImageGetHeight(imageRef))
        CGContextDrawImage(context, rect, imageRef)
        
        let decompressedImageRef = CGBitmapContextCreateImage(context)
        return UIImage(CGImage: decompressedImageRef!)
    }
    
}
