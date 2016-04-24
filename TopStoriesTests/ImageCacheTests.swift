//
//  ImageCacheTests.swift
//  TopStories
//
//  Created by Sam Meadley on 24/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import XCTest

@testable import TopStories

class ImageCacheTests: XCTestCase {

    // MARK: - imageForURL(_:)
    
    func testImageForURL_imageInCache() {
     
        // Arrange
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource("image", ofType: "jpg")!
        let expectedImage = UIImage(contentsOfFile: path)!
        let URL = "http://www.example.com/image.jpg"
        
        let cache = NSCache()
        cache.setObject(expectedImage, forKey: URL)
        
        let imageCache = ImageCache(cache: cache, fileManager: NSFileManager.defaultManager())
        
        // Act
        let image = imageCache.imageForURL(URL)
        
        // Assert
        XCTAssertEqual(image, expectedImage)
    }

    func testImageForURL_imageNotInCache() {
        
        // Arrange
        let cache = NSCache()
        
        let URL = "http://www.example.com/image.jpg"

        let fileManager = TestableFileManager()
        fileManager.stubFileExistsAtPath = false
        
        let imageCache = ImageCache(cache: cache, fileManager: fileManager)
        
        // Act
        let image = imageCache.imageForURL(URL)
        
        // Assert
        XCTAssertNil(image)
    }
    
    // MARK - setImage(_:forURL:temporaryFileURL:)
    
    func testSetImageForURL_temporaryFileExists() {
        
        // Arrange
        let bundle = NSBundle(forClass: self.dynamicType)
        let temporaryFileURL = bundle.URLForResource("image", withExtension: "jpg")!
        let expectedImage = UIImage(contentsOfFile: temporaryFileURL.path!)!
        let URL = "http://www.example.com/image.jpg"
        
        let cache = NSCache()
        
        let fileManager = TestableFileManager()
        let imageCache = ImageCache(cache: cache, fileManager: fileManager)
        
        // Act
        imageCache.setImage(expectedImage, forURL: URL, temporaryFileURL: temporaryFileURL)
        
        // Assert
        let image = imageCache.imageForURL(URL)
        XCTAssertEqual(image, expectedImage)
        XCTAssertNotNil(fileManager.destinationOfMovedItem)
    }
    
    func testSetImageForURL_temporaryFileNotFound() {
        
        // Arrange
        let bundle = NSBundle(forClass: self.dynamicType)
        let temporaryFileURL = bundle.URLForResource("image", withExtension: "jpg")!
        let expectedImage = UIImage(contentsOfFile: temporaryFileURL.path!)!
        let URL = "http://www.example.com/image.jpg"
        
        let cache = NSCache()
        
        let fileManager = TestableFileManager()
        let imageCache = ImageCache(cache: cache, fileManager: fileManager)
        
        // Act
        imageCache.setImage(expectedImage, forURL: URL, temporaryFileURL: NSURL())
        
        // Assert
        let image = imageCache.imageForURL(URL)
        XCTAssertEqual(image, expectedImage)
        XCTAssertNil(fileManager.destinationOfMovedItem)
    }
    
    // MARK - URLForCachedImageForKey(_:)
    
    func testURLForCachedImageForKey() {
        
        // Arrange
        let key = "http://www.example.com/image.jpg"
        
        // Act
        let imageCache = ImageCache()
        
        do {
            let URL = try imageCache.URLForCachedImageForKey(key)
            
            // Assert
            let expectedSuffix = "/Library/Caches/fbef9ea4cf2f8b617a030743b49d3097"
            XCTAssertTrue(URL.absoluteString.hasSuffix(expectedSuffix))
            
        } catch {
            XCTFail()
        }
    }
}
