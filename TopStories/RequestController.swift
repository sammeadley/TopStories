//
//  RequestController.swift
//  TopStories
//
//  Created by Sam Meadley on 19/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import Foundation
import CoreData

class RequestController {

    var managedObjectContext: NSManagedObjectContext
    var URLSession: NSURLSession?
    
    private let operationQueue = NSOperationQueue()
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    func requestTopStories() -> NSFetchedResultsController {
     
        let APIKey = "015e7acf5628e1337cd461eff1cf7283:18:75044656"
        let defaultSection = "home"
        let responseFormat = "json"
        
        let URLComponents = NSURLComponents(string: "http://api.nytimes.com/svc/topstories/v1/")
        URLComponents?.path = (URLComponents?.path)! + "\(defaultSection).\(responseFormat)"
        URLComponents?.queryItems = [ NSURLQueryItem(name: "api-key", value: APIKey) ]
        
        let request = TopStoriesRequest(managedObjectContext: managedObjectContext, URL: URLComponents!.URL!)
        
        operationQueue.addOperation(request)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: Story.fetchRequest(),
                                                                  managedObjectContext: managedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsController
    }
    
}
