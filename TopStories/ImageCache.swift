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
            
            guard let image = UIImage(data: data) else {
                return nil
            }
            
            setImage(image, forURL: URL)
            return image
            
        } catch {
            return nil
        }
    }
    
    func setImage(image: UIImage, forURL URL: String) {
        
        cache.setObject(image, forKey: URL)
    }
    
}

// MARK:- Private methods

private extension ImageCache {
    
    func URLForCachedImageForKey(key: String) throws -> NSURL {
        
        let URLs = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        guard let URL = URLs.last else {
            throw ImageCacheError.CachesDirectoryNotFound
        }
        
        return URL.URLByAppendingPathComponent(key)
    }
    
}

// MARK:- Error Types

enum ImageCacheError: ErrorType {
    case CachesDirectoryNotFound
}
