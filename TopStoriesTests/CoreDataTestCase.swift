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
    
}