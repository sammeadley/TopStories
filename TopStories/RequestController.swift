//
//  RequestController.swift
//  TopStories
//
//  Created by Sam Meadley on 19/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit
import CoreData

final class RequestController: NSObject {
    
    var managedObjectContext: NSManagedObjectContext
    
    private let imageCache: ImageCache
    
    private lazy var operationQueue: OperationQueue = {
        
        let operationQueue = OperationQueue()
        operationQueue.addObserver(self,
                                   forKeyPath: "operationCount",
                                   options: NSKeyValueObservingOptions.new,
                                   context: nil)
        
        return operationQueue
    }()
    
    private let urlSession: URLSession?
    
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
         urlSession: URLSession? = nil,
         imageCache: ImageCache = ImageCache()) {
        self.managedObjectContext = managedObjectContext
        self.urlSession = urlSession
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
    @discardableResult
    func requestTopStories() -> NSFetchedResultsController<NSFetchRequestResult> {
        
        // A production app would not store the API key here.
        let apiKey = "514c06bb180a4ec5b18e11c64479fee7"
        let defaultSection = "home"
        let responseFormat = "json"
        
        var urlComponents = URLComponents(string: "http://api.nytimes.com/svc/topstories/v1/")
        urlComponents?.path = (urlComponents?.path)! + "\(defaultSection).\(responseFormat)"
        urlComponents?.queryItems = [ URLQueryItem(name: "api-key", value: apiKey) ]
        
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: Story.fetchRequest(),
                                                                  managedObjectContext: managedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            // TODO: Handle error
        }
        
        let request = TopStoriesRequest(managedObjectContext: managedObjectContext, URL: urlComponents!.url!)
        request.urlSession = urlSession
        
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
    func requestImage(for story: Story,
                      imageSize: Story.ImageSize = .default,
                      observer: AnyObject? = nil,
                      selector: Selector? = nil) -> UIImage? {
        
        guard let imageURL = story.imageURL(for: imageSize) else {
            return nil
        }
        
        if let image = imageCache.imageForURL(imageURL) {
            return image
        }
        
        let request = ImageRequest(story: story, cache: imageCache, imageSize: imageSize)
        request.urlSession = urlSession
        
        if let observer = observer, let selector = selector {
            NotificationCenter.default.addObserver(observer,
                                                   selector: selector,
                                                   name: .imageRequestDidComplete,
                                                   object: request)
        }
        
        if !operationQueue.operations.contains(request) {
            operationQueue.addOperation(request)
        }
        
        return nil
    }
}

// MARK: - KVO
extension RequestController {
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        guard keyPath == "operationCount" else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if let operationCount = change?[NSKeyValueChangeKey.newKey] as? Int {
            let showNetworkActivityIndicator = operationCount > 0;
            
            let sharedApplication = UIApplication.shared
            sharedApplication.isNetworkActivityIndicatorVisible = showNetworkActivityIndicator
        }
    }
}
