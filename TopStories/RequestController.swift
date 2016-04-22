//
//  RequestController.swift
//  TopStories
//
//  Created by Sam Meadley on 19/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit
import CoreData

class RequestController {

    enum Notifications {
        static let ImageRequestDidComplete = "com.sammeadley.TopStories.ImageRequestDidComplete"
        
        enum Keys {
            static let Image = "image"
            static let Story = "story"
        }
    }
    
    var managedObjectContext: NSManagedObjectContext
    var URLSession: NSURLSession?
    
    private let operationQueue = NSOperationQueue()
    private let imageCache = ImageCache()
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    /**
     Performs top stories API request
     
     Requests the top stories from the home section of the NYTimes API, and stores the parsed
     Story entities to the Core Data cache. The returned NSFetchedResultsController instance is 
     configured to monitor the Story entities and the delegate will be triggered for any update.
 
     Consuming classes should use the returned NSFetchedResultsController instance to make any
     changes to view content.
     
     - returns: NSFetchedResultsController instance configured to monitor Story entities.
     */
    func requestTopStories() -> NSFetchedResultsController {
     
        let APIKey = "015e7acf5628e1337cd461eff1cf7283:18:75044656"
        let defaultSection = "home"
        let responseFormat = "json"
        
        let URLComponents = NSURLComponents(string: "http://api.nytimes.com/svc/topstories/v1/")
        URLComponents?.path = (URLComponents?.path)! + "\(defaultSection).\(responseFormat)"
        URLComponents?.queryItems = [ NSURLQueryItem(name: "api-key", value: APIKey) ]
        
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: Story.fetchRequest(),
                                                                  managedObjectContext: managedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            // TODO: Handle error
        }
        
        let request = TopStoriesRequest(managedObjectContext: managedObjectContext, URL: URLComponents!.URL!)
        operationQueue.addOperation(request)
        
        return fetchedResultsController
    }
    
    /**
     Requests the image referred to by the story's imageURL.
     
     Checks the in-memory and disk caches before making a network request.
     If the image is cached, the function returns the cached image.
     
     It is recommended that this function be called from a background thread, as fetching an image
     from the disk cache can be slow.
     
     - parameter story: The story containing the imageURL to load.
     
     - returns: The image if cached, otherwise nil.
     */
    func requestImageForStory(story: Story) -> UIImage? {
        
        guard let imageURL = story.imageURL else {
            return nil
        }
        
        if let image = imageCache.imageForURL(imageURL) {
            return image
        }
        
        let request = ImageRequest(story: story, cache: imageCache)
        if !operationQueue.operations.contains(request) {
            operationQueue.addOperation(request)
        }
        
        return nil
    }
    
}
