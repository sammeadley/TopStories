//
//  Story.swift
//  TopStories
//
//  Created by Sam Meadley on 20/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import Foundation
import CoreData

class Story: NSManagedObject {

    class func fetchRequest() -> NSFetchRequest {
        
        let fetchRequest = NSFetchRequest(entityName: String(Story))
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key:"publishedDate", ascending: false) ]
        
        return fetchRequest
    }
    
    class func instancesForContentURLs(URLs: [String],
                                       managedObjectContext: NSManagedObjectContext) -> [Story]? {
        
        let results = self.instancesInManagedObjectContext(managedObjectContext,
                                                           predicate: NSPredicate(format: "contentURL in %@", URLs))
        return results
    }
    
    class func instancesInManagedObjectContext(managedObjectContext: NSManagedObjectContext,
                                               predicate: NSPredicate? = nil) -> [Story]? {
        
        let fetchRequest = self.fetchRequest()
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest)
            return results as? [Story]
            
        } catch {
            // TODO: Handle error
            return nil
        }
    }

}
