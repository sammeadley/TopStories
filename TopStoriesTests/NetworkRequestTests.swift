//
//  TopStoriesRequestTests.swift
//  TopStories
//
//  Created by Sam Meadley on 20/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import XCTest
import CoreData

@testable import TopStories

class TopStoriesRequestTests: CoreDataTestCase {

    var expectation: XCTestExpectation?
    
    func testStart() {
        
        // Arrange
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource("home", ofType: "json")
        let data = NSData(contentsOfFile: path!)
        
        let request = TopStoriesRequest(managedObjectContext: persistenceController.managedObjectContext,
                                        URL: NSURL())

        let URLSession = TestableURLSession(delegate: request)
        let task = TestableURLSessionDataTask(URLSession: URLSession)
        task.stubData = data
        URLSession.stubDataTask = task
        
        request.URLSession = URLSession
        
        // Act
        request.start()
        
        // Assert
        expectation = expectationWithDescription("testStart")
        
        // Operation internally dispatches async block operations to update private/main MOCs.
        // As this is done asyncronously, we listen for NSManagedObjectContextDidSaveNotification before
        // attempting the assert stage.
        //
        // We could KVO the request operation's isFinished, which would work just as well. However
        // that would mean implementing observeValueForKeyPath(_:ofObject:change:context:).
        // This way we keep all test logic together.
        let defaultCenter = NSNotificationCenter.defaultCenter()
        let observer = defaultCenter.addObserverForName(NSManagedObjectContextDidSaveNotification,
                                                        object: persistenceController.managedObjectContext,
                                                        queue: nil,
                                                        usingBlock: { notification in
                                                            
                                                            let stories = Story.instancesInManagedObjectContext(self.persistenceController.managedObjectContext)
                                                            
                                                            XCTAssertEqual(stories?.count, 24)
                                                            
                                                            self.expectation?.fulfill()
        })
        
        waitForExpectationsWithTimeout(2.0, handler: { error in
            
            // Cleanup
            defaultCenter.removeObserver(observer)
        })
    }
    
}
