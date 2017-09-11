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
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "home", ofType: "json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: path!))
        
        let request = TopStoriesRequest(managedObjectContext: persistenceController.managedObjectContext,
                                        URL: URL.fake)

        let urlSession = TestableURLSession(delegate: request)
        let task = TestableURLSessionDataTask(urlSession: urlSession)
        task.stubData = data
        urlSession.stubTask = task
        
        request.urlSession = urlSession
        
        // Act
        request.start()
        
        // Assert
        expectation = self.expectation(description: "testStart")
        
        // Operation internally dispatches async block operations to update private/main MOCs.
        // As this is done asyncronously, we listen for NSManagedObjectContextDidSaveNotification before
        // attempting the assert stage.
        //
        // We could KVO the request operation's isFinished, which would work just as well. However
        // that would mean implementing observeValueForKeyPath(_:ofObject:change:context:).
        // This way we keep all test logic together.
        let defaultCenter = NotificationCenter.default
        let observer = defaultCenter.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave,
                                                        object: persistenceController.managedObjectContext,
                                                        queue: nil,
                                                        using: { notification in
                                                            
                                                            let stories = Story.instancesInManagedObjectContext(self.persistenceController.managedObjectContext)
                                                            
                                                            XCTAssertEqual(stories?.count, 24)
                                                            
                                                            self.expectation?.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: { error in
            
            // Cleanup
            defaultCenter.removeObserver(observer)
        })
    }
    
}
