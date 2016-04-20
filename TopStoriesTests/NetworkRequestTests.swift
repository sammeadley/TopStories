//
//  TopStoriesRequestTests.swift
//  TopStories
//
//  Created by Sam Meadley on 20/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import XCTest
@testable import TopStories

class TopStoriesRequestTests: XCTestCase {

    var expectation: XCTestExpectation?
    
    func testStart() {
        
        // Arrange
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource("home", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        
        let request = TopStoriesRequest(managedObjectContext: nil, URL: NSURL())

        let URLSession = TestableURLSession(delegate: request)
        let task = TestableURLSessionDataTask(URLSession: URLSession)
        task.stubData = data
        URLSession.stubDataTask = task
        
        request.URLSession = URLSession
        
        expectation = expectationWithDescription("testStart")
        
        // Act
        request.start()
        
        // Assert
    }
    
}
