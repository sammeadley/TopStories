//
//  TopStoriesRequest.swift
//  TopStories
//
//  Created by Sam Meadley on 20/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import Foundation
import CoreData

class TopStoriesRequest: NetworkRequest {
    
    var URLSession: NSURLSession?
    
    private let managedObjectContext: NSManagedObjectContext
    private let URL: NSURL
    
    init(managedObjectContext: NSManagedObjectContext, URL: NSURL) {
        self.managedObjectContext = managedObjectContext
        self.URL = URL
        
        super.init()
        self.queuePriority = .Normal
        self.qualityOfService = .UserInitiated
    }
    
    // MARK: - NSOperation
    
    override func start() {
        
        if (URLSession == nil) {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            URLSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        }
        
        task = URLSession?.dataTaskWithURL(URL)
        task?.resume()
    }
    
    // MARK: - NSURLSessionDataDelegate
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        if cancelled {
            self.state = .Finished
            self.task?.cancel()
            return
        }
        
        if error != nil {
            self.error = error
            NSLog("Failed to receive response: \(error)")
            self.state = .Finished
            return
        }
        
        do {
            guard let JSONObject = try NSJSONSerialization.JSONObjectWithData(self.data,
                                                                              options: []) as? Dictionary<String, AnyObject> else {
                                                                                return;
            }
            
            let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            privateContext.parentContext = managedObjectContext
            privateContext.performBlock({
                
                let results = JSONObject["results"] as! [Dictionary<String, AnyObject>]
                let URLs = results.map({ $0["url"] as! String })
                // Fetch existing records at once, so there's only a single hit on the database.
                let existing = Story.instancesForContentURLs(URLs, managedObjectContext: privateContext)
                
                _ = results.map({ storyJSON in
                    
                    var story: Story
                    if let index = (existing?.map({ $0.contentURL }).indexOf({ $0 == storyJSON["url"] as? String })) {
                        story = existing![index]
                    } else {
                        story = NSEntityDescription.insertNewObjectForEntityForName(String(Story),
                            inManagedObjectContext: privateContext) as! Story
                    }
                    
                    story.abstract = storyJSON["abstract"] as? String
                    story.contentURL = storyJSON["url"] as? String
                    
                    if let multimedia = storyJSON["multimedia"] as? [Dictionary<String, AnyObject>] {
                        if let index = multimedia.indexOf({ $0["format"] as? String == "thumbLarge"}) {
                            let item = multimedia[index]
                            story.imageURL = item["url"] as? String
                        }                        
                    }
                    
                    story.publishedDate = NSDate() // TODO: Parse published date
                    story.title = storyJSON["title"] as? String
                })
                
                // Push changes to parent context
                do {
                    try privateContext.save()
                } catch {
                    self.error = error as NSError
                    self.state = .Finished
                    return
                }
                
                // Save parent context to disk
                self.managedObjectContext.performBlock({
                    
                    do {
                        try self.managedObjectContext.save()
                    } catch {
                        self.error = error as NSError
                        self.state = .Finished
                        return
                    }
                })
            })
            
        } catch {

            self.error = error as NSError
        }
        
        self.state = .Finished
    }
    
}
