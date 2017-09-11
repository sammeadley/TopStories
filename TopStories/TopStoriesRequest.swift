//
//  TopStoriesRequest.swift
//  TopStories
//
//  Created by Sam Meadley on 20/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import Foundation
import CoreData
import ISO8601

class TopStoriesRequest: NetworkRequest {
    
    var urlSession: Foundation.URLSession?
    
    fileprivate let managedObjectContext: NSManagedObjectContext
    fileprivate let URL: Foundation.URL
    
    /**
     Initializes the request with dependencies.
     
     - parameter managedObjectContext: The parent MainQueue context, branch any children off this context.
     - parameter URL: The URL of the top stories JSON.
     */
    init(managedObjectContext: NSManagedObjectContext, URL: Foundation.URL) {
        self.managedObjectContext = managedObjectContext
        self.URL = URL
        
        super.init()
        self.queuePriority = .normal
        self.qualityOfService = .userInitiated
    }
    
    // MARK: - NSOperation
    
    override func start() {
        
        if (urlSession == nil) {
            let configuration = URLSessionConfiguration.default
            urlSession = Foundation.URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        }
        
        task = urlSession?.dataTask(with: URL)
        task?.resume()
    }
    
    // MARK: - NSURLSessionDataDelegate
    
    func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        
        if isCancelled {
            self.state = .finished
            self.task?.cancel()
            return
        }
        
        if error != nil {
            self.error = .networkError(error)
            self.state = .finished
            return
        }
        
        do {
            guard let JSONObject = try JSONSerialization.jsonObject(with: self.data as Data,
                                                                              options: []) as? Dictionary<String, AnyObject> else {
                                                                                return;
            }
            
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateContext.parent = managedObjectContext
            privateContext.perform({
                
                let results = JSONObject["results"] as! [Dictionary<String, AnyObject>]
                let URLs = results.map({ $0["url"] as! String })
                // Fetch existing records at once, so there's only a single hit on the database.
                let existing = Story.instancesForContentURLs(URLs, managedObjectContext: privateContext)
                
                _ = results.map({ storyJSON in
                    
                    var story: Story
                    if let index = (existing?.map({ $0.contentURL }).index(where: { $0 == storyJSON["url"] as? String })) {
                        story = existing![index]
                    } else {
                        story = NSEntityDescription.insertNewObject(forEntityName: String(describing: Story.self),
                            into: privateContext) as! Story
                    }
                    
                    story.abstract = storyJSON["abstract"] as? String
                    story.contentURL = storyJSON["url"] as? String
                    
                    if let multimedia = storyJSON["multimedia"] as? [Dictionary<String, AnyObject>] {
                        if let index = multimedia.index(where: { $0["format"] as? String == "superJumbo"}) {
                            let item = multimedia[index]
                            story.imageURL = item["url"] as? String
                        }
                        
                        if let index = multimedia.index(where: { $0["format"] as? String == "thumbLarge"}) {
                            let item = multimedia[index]
                            story.thumbnailURL = item["url"] as? String
                        }
                    }
                    
                    if let createdDate = storyJSON["created_date"] as? String {
                        let formatter = ISO8601.ISO8601DateFormatter.formatter
                        story.createdDate = formatter.date(from: createdDate)
                    }
                    
                    story.title = storyJSON["title"] as? String
                })
                
                // Push changes to parent context
                do {
                    try privateContext.save()
                } catch {
                    self.error = .clientError("Failed to push changes to parent context.", error as NSError)
                    self.state = .finished
                    return
                }
                
                // Save parent context to disk
                self.managedObjectContext.perform({
                    
                    do {
                        try self.managedObjectContext.save()
                    } catch {
                        self.error = .clientError("Failed to save parent context changes to disk.", error as NSError)
                        self.state = .finished
                        return
                    }
                })
            })
            
        } catch {

            self.error = .clientError("Failed to deserialize JSON object.", error as NSError)
        }
        
        state = .finished
    }
    
}

// MARK: - ISO8601DateFormatter extensions

extension ISO8601.ISO8601DateFormatter {
    
    /**
     Reusable formatter instance to help performance.
     */
    fileprivate static let formatter: ISO8601.ISO8601DateFormatter = {
        let formatter = ISO8601.ISO8601DateFormatter()
        return formatter
    }()
    
}
