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
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "image", ofType: "jpg")!
        let expectedImage = UIImage(contentsOfFile: path)!
        let url = "http://www.example.com/image.jpg"
        
        let cache = NSCache<NSString, UIImage>()
        cache.setObject(expectedImage, forKey: url as NSString)
        
        let imageCache = ImageCache(cache: cache, fileManager: FileManager.default)
        
        // Act
        let image = imageCache.imageForURL(url)
        
        // Assert
        XCTAssertEqual(image, expectedImage)
    }

    func testImageForURL_imageNotInCache() {
        
        // Arrange
        let cache = NSCache<NSString, UIImage>()
        
        let url = "http://www.example.com/image.jpg"

        let fileManager = TestableFileManager()
        fileManager.stubFileExistsAtPath = false
        
        let imageCache = ImageCache(cache: cache, fileManager: fileManager)
        
        // Act
        let image = imageCache.imageForURL(url)
        
        // Assert
        XCTAssertNil(image)
    }
    
    // MARK - setImage(_:forURL:temporaryFileURL:)
    
    func testSetImageForURL_temporaryFileExists() {
        
        // Arrange
        let bundle = Bundle(for: type(of: self))
        let temporaryFileURL = bundle.url(forResource: "image", withExtension: "jpg")!
        let expectedImage = UIImage(contentsOfFile: temporaryFileURL.path)!
        let url = "http://www.example.com/image.jpg"
        
        let cache = NSCache<NSString, UIImage>()
        
        let fileManager = TestableFileManager()
        let imageCache = ImageCache(cache: cache, fileManager: fileManager)
        
        // Act
        imageCache.setImage(expectedImage, forURL: url, temporaryFileURL: temporaryFileURL)
        
        // Assert
        let image = imageCache.imageForURL(url)
        XCTAssertEqual(image, expectedImage)
        XCTAssertNotNil(fileManager.destinationOfMovedItem)
    }
    
    func testSetImageForURL_temporaryFileNotFound() {
        
        // Arrange
        let bundle = Bundle(for: type(of: self))
        let temporaryFileURL = bundle.url(forResource: "image", withExtension: "jpg")!
        let expectedImage = UIImage(contentsOfFile: temporaryFileURL.path)!
        let url = "http://www.example.com/image.jpg"
        
        let cache = NSCache<NSString, UIImage>()
        
        let fileManager = TestableFileManager()
        let imageCache = ImageCache(cache: cache, fileManager: fileManager)
        
        // Act
        imageCache.setImage(expectedImage, forURL: url, temporaryFileURL: URL(string: "±"))
        
        // Assert
        let image = imageCache.imageForURL(url)
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
            let URL = try imageCache.urlForCachedImageForKey(key)
            
            // Assert
            let expectedSuffix = "/Library/Caches/fbef9ea4cf2f8b617a030743b49d3097"
            XCTAssertTrue(URL.absoluteString.hasSuffix(expectedSuffix))
            
        } catch {
            XCTFail()
        }
    }
}
