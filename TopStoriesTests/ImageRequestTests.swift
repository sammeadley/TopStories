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
    
    weak var expectation: XCTestExpectation?
    
    func testStart() {
        
        // Arrange
        let bundle = Bundle(for: type(of: self))
        let URL = bundle.url(forResource: "image", withExtension: "jpg")
        
        let dummyStory = story()
        let imageCache = ImageCache(cache: NSCache(), fileManager: TestableFileManager())
        let request = ImageRequest(story: dummyStory,
                                   cache: imageCache,
                                   imageSize: .default)
        
        let urlSession = TestableURLSession(delegate: request)
        let task = TestableURLSessionDownloadTask(urlSession: urlSession)
        task.stubDownloadLocation = URL
        urlSession.stubTask = task
        
        request.urlSession = urlSession
        
        // Act
        request.start()
        
        // Assert
        XCTAssertNotNil(imageCache.imageForURL(dummyStory.imageURL!)) // Check membership of in-memory cache
        
        expectation = self.expectation(description: "testStart")
        
        let defaultCenter = NotificationCenter.default
        let observer = defaultCenter.addObserver(forName: .imageRequestDidComplete,
                                                 object: nil,
                                                 queue: nil,
                                                 using: { notification in
                                                    
                                                    guard let userInfo = notification.userInfo else {
                                                        return
                                                    }
                                                    
                                                    let image = userInfo[ImageRequestDidCompleteUserInfoKeys.image] as? UIImage
                                                    let story = userInfo[ImageRequestDidCompleteUserInfoKeys.story] as? Story
                                                    
                                                    XCTAssertNotNil(image)
                                                    XCTAssertEqual(story, dummyStory)
                                                    
                                                    self.expectation?.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: { error in
            
            // Cleanup
            defaultCenter.removeObserver(observer)
        })
    }
    
}
