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

    /**
     Default fetch request for Story entities.
     
     Returns a fetch request configured to return Story entities, sorted by date created descending.
     
     - returns: NSFetchRequest instance for Story entities.
     */
    override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: self))
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "createdDate", ascending: false) ]
        
        return fetchRequest
    }
    
    /**
     Lookup Story instances by contentURL value.
     
     Looks up Story instances based on contentURL value. Ideally we would use something like a unique
     identifier here to refer to unique instances. The API doesn't provide us with such, so we'll
     key off contentURL.
     
     - parameter URLs: Array of contentURLs used to perform the story lookup.
     - parameter managedObjectContext: The managedObjectContext instance to execute a fetch against.
     
     - returns: Array Story entities matching the contentURLs.
     */
    class func instancesForContentURLs(_ URLs: [String],
                                       managedObjectContext: NSManagedObjectContext) -> [Story]? {
        
        let results = self.instancesInManagedObjectContext(managedObjectContext,
                                                           predicate: NSPredicate(format: "contentURL in %@", URLs))
        return results
    }
    
    /**
     Lookup Story instances by predicate.
     
     Looks up Story instances based on a supplied predicate.
     
     - parameter managedObjectContext: The managedObjectContext instance to execute a fetch against.
     - parameter predicate: The predicate to use in the fetch request.
     
     - returns: Array Story entities matching the predicate.
     */
    class func instancesInManagedObjectContext(_ managedObjectContext: NSManagedObjectContext,
                                               predicate: NSPredicate? = nil) -> [Story]? {
        
        let fetchRequest = self.fetchRequest()
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results as? [Story]
            
        } catch {
            // TODO: Handle error
            return nil
        }
    }
    
    /**
     Return image URL by desired size.
     
     - parameter imageSize: The desired image size, see ImageSize for options.
     
     - returns: Image URL string.
     */
    func imageURL(for imageSize: ImageSize) -> String? {
        switch imageSize {
        case .default:
            return imageURL
        case .thumbnail:
            return thumbnailURL
        }
    }

    /**
     Use with imageURLForSize(_:) to return the correct URL for the desired size.
     */
    enum ImageSize: Int {
        case `default`
        case thumbnail
    }
    
}
