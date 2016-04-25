//
//  ImageRequestTests.swift
//  TopStories
//
//  Created by Sam Meadley on 25/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import XCTest

@testable import TopStories

class ImageRequestTests: CoreDataTestCase {

    var expectation: XCTestExpectation?
    
    func testStart() {
        
        // Arrange
        let bundle = NSBundle(forClass: self.dynamicType)
        let URL = bundle.URLForResource("image", withExtension: "jpg")
        
        let dummyStory = story()
        let imageCache = ImageCache(cache: NSCache(), fileManager: TestableFileManager())
        let request = ImageRequest(story: dummyStory,
                                   cache: imageCache,
                                   imageSize: .Default)
        
        let URLSession = TestableURLSession(delegate: request)
        let task = TestableURLSessionDownloadTask(URLSession: URLSession)
        task.stubDownloadLocation = URL
        URLSession.stubTask = task
        
        request.URLSession = URLSession
        
        // Act
        request.start()
        
        // Assert
        XCTAssertNotNil(imageCache.imageForURL(dummyStory.imageURL!)) // Check membership of in-memory cache
        
        expectation = expectationWithDescription("testStart")
        
        let defaultCenter = NSNotificationCenter.defaultCenter()
        let observer = defaultCenter.addObserverForName(RequestController.Notifications.ImageRequestDidComplete,
                                                        object: nil,
                                                        queue: nil,
                                                        usingBlock: { notification in
                                                            
                                                            guard let userInfo = notification.userInfo else {
                                                                return
                                                            }
                                                            
                                                            let image = userInfo[RequestController.Notifications.Keys.Image] as? UIImage
                                                            let story = userInfo[RequestController.Notifications.Keys.Story] as? Story
                                                            
                                                            XCTAssertNotNil(image)
                                                            XCTAssertEqual(story, dummyStory)
                                                            
                                                            self.expectation?.fulfill()
        })
        
        waitForExpectationsWithTimeout(2.0, handler: { error in
            
            // Cleanup
            defaultCenter.removeObserver(observer)
        })
    }

}
