//
//  RequestController.swift
//  TopStories
//
//  Created by Sam Meadley on 19/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit
import CoreData

class RequestController: NSObject {

    // MARK: - Notifications and Keys
    
    enum Notifications {
        static let ImageRequestDidComplete = "com.sammeadley.TopStories.ImageRequestDidComplete"
        
        enum Keys {
            static let Image = "image"
            static let Story = "story"
        }
    }
    
    // MARK: - Properties
    
    var managedObjectContext: NSManagedObjectContext
    
    private let URLSession: NSURLSession?
    private let imageCache: ImageCache
    private lazy var operationQueue: NSOperationQueue = {
        
        let operationQueue = NSOperationQueue()
        operationQueue.addObserver(self,
                                   forKeyPath: "operationCount", 
                                   options: NSKeyValueObservingOptions.New,
                                   context: nil)
        
        return operationQueue
    }()
    
    /**
     Initializes the request controller with dependencies.
     
     - parameter managedObjectContext:  The main managed object context to use as the parent for any
                                        child contexts that may be created to store downloaded entities.
     
     - parameter URLSession:    URLSession to use for any requests; optional- if nil individual
                                requests will manage their own session. Primarily for testing.
     
     - parameter imageCache:    The ImageCache instance to interrogate for membership; optional-
                                if nil a new ImageCache instance will be created. Primarily for 
                                testing.
     */
    init(managedObjectContext: NSManagedObjectContext,
         URLSession: NSURLSession? = nil,
         imageCache: ImageCache = ImageCache()) {
        self.managedObjectContext = managedObjectContext
        self.URLSession = URLSession
        self.imageCache = imageCache
        
        super.init()
    }
    
    deinit {        
        operationQueue.removeObserver(self, forKeyPath: "operationCount")
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
        request.URLSession = URLSession
        
        operationQueue.addOperation(request)
        
        return fetchedResultsController
    }
    
    /**
     Requests the image referred to by the story's imageURL.
     
     Checks the in-memory and disk caches before making a network request.
     If the image is cached, the function returns the cached image.
     
     It is recommended that this function be called from a background thread, as fetching an image
     from the disk cache can be slow.
     
     If the image is not cached, it will be fetched from the network. A .ImageRequestDidComplete
     notification will be posted on the main queue once complete.
     
     - parameter story:     The story containing the imageURL to load.
     - parameter imageSize: The size of the image to download, .Default by default.
     - parameter observer:  The observer to be notified when the image download completes. If nil
                            the observer will not be added.
     - parameter selector:  The method to call on receipt of the notification.
     
     - returns: The image if cached, otherwise nil.
     */
    func requestImageForStory(story: Story,
                              imageSize: Story.ImageSize = .Default,
                              observer: AnyObject? = nil,
                              selector: Selector? = nil) -> UIImage? {
        
        guard let imageURL = story.imageURLForSize(imageSize) else {
            return nil
        }
        
        if let image = imageCache.imageForURL(imageURL) {
            return image
        }
        
        let request = ImageRequest(story: story, cache: imageCache, imageSize: imageSize)
        request.URLSession = URLSession
        
        if let observer = observer, selector = selector {
            NSNotificationCenter.defaultCenter().addObserver(observer,
                                                             selector: selector,
                                                             name: Notifications.ImageRequestDidComplete,
                                                             object: request)
        }
        
        if !operationQueue.operations.contains(request) {
            operationQueue.addOperation(request)
        }
        
        return nil
    }
    
}

extension RequestController {
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String?,
                                         ofObject object: AnyObject?,
                                                  change: [String : AnyObject]?, 
                                                  context: UnsafeMutablePointer<Void>) {
        
        guard keyPath == "operationCount" else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        if let operationCount = change?[NSKeyValueChangeNewKey] as? Int {
            let showNetworkActivityIndicator = operationCount > 0;
            
            let sharedApplication = UIApplication.sharedApplication()
            sharedApplication.networkActivityIndicatorVisible = showNetworkActivityIndicator
        }
        
    }

}
