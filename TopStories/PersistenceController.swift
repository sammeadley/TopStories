//
//  PersistenceController.swift
//  TopStories
//
//  Created by Sam Meadley on 19/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import Foundation
import CoreData

class PersistenceController {
    
    private let storeType: String
    
    /**
     Initializes the persistence controller with a persistent store type.
     
     We allow customization of the persistent store type primarily for testing purposes (NSInMemoryStoreType). 
     A default value NSSQLiteStoreType is set, so by default a SQLite store type is used.
     
     - parameter storeType: A string representing the store type. NSSQLiteStoreType by default.
     */
    init(storeType: String = NSSQLiteStoreType) {
        self.storeType = storeType
    }
    
    /**
     The main Managed Object Context instance, any other created contexts will become children of 
     this one and push changes up the hierarchy.
     */
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        
        // The managed object model for the application. This property is not optional. 
        // It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("TopStories", withExtension: "momd")!
        
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    /**
     The persistent store coordinator manages a single SQLite store (or memory store for testing).
     The SQLite store is in Library/Caches as it is just a cache, and can be rebuilt. This way iOS 
     can clear it down if it comes under storage pressure.
     */
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        guard let URL = NSFileManager.defaultManager().URLForApplicationCachesDirectory()?.URLByAppendingPathComponent("TopStories.sqlite") else {
            return nil;
        }

        do {
            try coordinator.addPersistentStoreWithType(self.storeType, configuration: nil, URL: URL, options: nil)

        } catch {
            // TODO: Handle error
        }
        
        return coordinator
    }()
}


extension NSFileManager {
    
    /**
     The URL to the Application's Caches directory.
     
     - returns: NSURL containing the path to the Library/Caches, or nil.
     */
    func URLForApplicationCachesDirectory() -> NSURL? {
        
        let URLs = URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        let URL = URLs.last
        
        return URL;
    }
    
}

