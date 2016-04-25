//
//  RequestControllerTests.swift
//  TopStories
//
//  Created by Sam Meadley on 24/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import XCTest
import CoreData

@testable import TopStories

class RequestControllerTests: CoreDataTestCase {

    var expectation: XCTestExpectation?
    
    // MARK: - requestImageForStory(_:)
    
    func testRequestImageForStory_imageInMemoryCache() {
        
        // Arrange
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource("image", ofType: "jpg")!
        let expectedImage = UIImage(contentsOfFile: path)!
        let dummyStory = story()
        
        let cache = NSCache()
        cache.setObject(expectedImage, forKey: dummyStory.imageURL!)
        
        let imageCache = ImageCache(cache: cache, fileManager: NSFileManager.defaultManager())
        let requestController = RequestController(managedObjectContext: persistenceController.managedObjectContext,
                                                  URLSession: NSURLSession.sharedSession(),
                                                  imageCache: imageCache)
        // Act
        let image = requestController.requestImageForStory(dummyStory)
        
        // Assert
        XCTAssertEqual(image, expectedImage)
    }
    
    func testRequestImageForStory_imageInDiskCache() {
     
        // Arrange
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.URLForResource("image", withExtension: "jpg")
        let expectedImageData = NSData(contentsOfURL: (path?.absoluteURL)!)!
        let expectedImage = UIImage(data: expectedImageData)
        
        let cache = NSCache()
        
        let dummyStory = story()
        
        let fileManager = TestableFileManager()
        fileManager.stubContentsAtPath = expectedImageData
        fileManager.stubFileExistsAtPath = true
        
        let imageCache = ImageCache(cache: cache, fileManager: fileManager)
        let requestController = RequestController(managedObjectContext: persistenceController.managedObjectContext,
                                                  URLSession: NSURLSession.sharedSession(),
                                                  imageCache: imageCache)
        // Act
        let image = requestController.requestImageForStory(dummyStory)
        
        // Assert
        let expected = UIImageJPEGRepresentation(expectedImage!, 1)
        let actual = UIImageJPEGRepresentation(image!, 1)
        
        XCTAssertEqual(expected, actual)
        XCTAssertNotNil(cache.objectForKey((dummyStory.imageURL)!)) // Check membership of in-memory cache.
    }
    
    func testRequestImageForStory_imageNotCached() {
        
        // Arrange
        let dummyStory = story()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let URL = bundle.URLForResource("image", withExtension: "jpg")
        
        let URLSession = TestableURLSession(delegate: nil)
        let task = TestableURLSessionDownloadTask(URLSession: URLSession)
        task.stubDownloadLocation = URL
        URLSession.stubTask = task
        
        let requestController = RequestController(managedObjectContext: persistenceController.managedObjectContext,
                                                  URLSession: URLSession,
                                                  imageCache: ImageCache())

        // Act
        let image = requestController.requestImageForStory(dummyStory)
        
        // Assert
        XCTAssertNil(image);
    }
    
}
