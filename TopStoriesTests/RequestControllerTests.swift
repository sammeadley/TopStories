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
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "image", ofType: "jpg")!
        let expectedImage = UIImage(contentsOfFile: path)!
        let dummyStory = story()
        
        let cache = NSCache<NSString, UIImage>()
        cache.setObject(expectedImage, forKey: dummyStory.imageURL as NSString? ?? "")
        
        let imageCache = ImageCache(cache: cache, fileManager: FileManager.default)
        let requestController = RequestController(managedObjectContext: persistenceController.managedObjectContext,
                                                  urlSession: URLSession.shared,
                                                  imageCache: imageCache)
        // Act
        let image = requestController.requestImage(for: dummyStory)
        
        // Assert
        XCTAssertEqual(image, expectedImage)
    }
    
    func testRequestImageForStory_imageInDiskCache() {
     
        // Arrange
        let bundle = Bundle(for: type(of: self))
        let path = bundle.url(forResource: "image", withExtension: "jpg")
        let expectedImageData = try! Data(contentsOf: (path?.absoluteURL)!)
        let expectedImage = UIImage(data: expectedImageData)
        
        let cache = NSCache<NSString, UIImage>()
        
        let dummyStory = story()
        
        let fileManager = TestableFileManager()
        fileManager.stubContentsAtPath = expectedImageData
        fileManager.stubFileExistsAtPath = true
        
        let imageCache = ImageCache(cache: cache, fileManager: fileManager)
        let requestController = RequestController(managedObjectContext: persistenceController.managedObjectContext,
                                                  urlSession: URLSession.shared,
                                                  imageCache: imageCache)
        // Act
        let image = requestController.requestImage(for: dummyStory)
        
        // Assert
        let expected = UIImageJPEGRepresentation(expectedImage!, 1)
        let actual = UIImageJPEGRepresentation(image!, 1)
        
        XCTAssertEqual(expected, actual)
        XCTAssertNotNil(cache.object(forKey: dummyStory.imageURL as NSString!)) // Check membership of in-memory cache.
    }
    
    func testRequestImageForStory_imageNotCached() {
        
        // Arrange
        let dummyStory = story()
        
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "image", withExtension: "jpg")
        
        let urlSession = TestableURLSession(delegate: nil)
        let task = TestableURLSessionDownloadTask(urlSession: urlSession)
        task.stubDownloadLocation = url
        urlSession.stubTask = task
        
        let requestController = RequestController(managedObjectContext: persistenceController.managedObjectContext,
                                                  urlSession: urlSession,
                                                  imageCache: ImageCache())

        // Act
        let image = requestController.requestImage(for: dummyStory)
        
        // Assert
        XCTAssertNil(image);
    }
    
}
