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
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        
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
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        guard let URL = NSFileManager.defaultManager().URLForApplicationCachesDirectory()?.URLByAppendingPathComponent("TopStories.sqlite") else {
            return nil;
        }

        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: URL, options: nil)

        } catch {
            
            // TODO: Remove this temporary NSLog and report error to Framework/Server.
            let error = error as NSError
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
        
        return coordinator
    }()
}


extension NSFileManager {
    
    func URLForApplicationCachesDirectory() -> NSURL? {
        
        let URLs = URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        // URL is not optional, if URLsForDirectory returns an empty array.
        let URL = URLs.last
        
        return URL;
    }
    
}

