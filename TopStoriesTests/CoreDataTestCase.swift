//
//  CoreDataTestCase.swift
//  TopStories
//
//  Created by Sam Meadley on 20/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import XCTest
import CoreData

@testable import TopStories

class CoreDataTestCase: XCTestCase {
    
    let persistenceController = PersistenceController(storeType: NSInMemoryStoreType)
 
    func story() -> Story {
        let story = NSEntityDescription.insertNewObject(forEntityName: String(describing: Story.self),
                                                        into: persistenceController.managedObjectContext) as! Story
        story.imageURL = "http://www.example.com/image.jpg"
        
        return story
    }
}
