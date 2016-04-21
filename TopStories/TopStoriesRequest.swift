//
//  TopStoriesRequest.swift
//  TopStories
//
//  Created by Sam Meadley on 20/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import Foundation
import CoreData

class TopStoriesRequest: NSOperation, NSURLSessionDataDelegate {
    
    var error: NSError?
    var URLSession: NSURLSession?
    
    private var task: NSURLSessionTask?
    
    private let data = NSMutableData()
    private let managedObjectContext: NSManagedObjectContext
    private let URL: NSURL
    
    init(managedObjectContext: NSManagedObjectContext, URL: NSURL) {
        self.managedObjectContext = managedObjectContext
        self.URL = URL
        
        super.init()
        self.queuePriority = .Normal
        self.qualityOfService = .UserInitiated
    }
    
    // MARK: - Types
    
    enum State {
        case Ready, Executing, Finished
        func keyPath() -> String {
            switch self {
            case Ready:
                return "isReady"
            case Executing:
                return "isExecuting"
            case Finished:
                return "isFinished"
            }
        }
    }
    
    // MARK: - Properties
    
    private var state = State.Ready {
        willSet {
            willChangeValueForKey(newValue.keyPath())
            willChangeValueForKey(state.keyPath())
        }
        didSet {
            didChangeValueForKey(oldValue.keyPath())
            didChangeValueForKey(state.keyPath())
        }
    }
    
    // MARK: - NSOperation
    
    override var ready: Bool {
        return super.ready && state == .Ready
    }
    
    override var executing: Bool {
        return state == .Executing
    }
    
    override var finished: Bool {
        return state == .Finished
    }
    
    override var asynchronous: Bool {
        return true
    }
    
    override func start() {
        
        if (URLSession == nil) {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            URLSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        }
        
        task = URLSession?.dataTaskWithURL(URL)
        task?.resume()
    }
    
    // MARK: - NSURLSessionDelegate
    
    func URLSession(session: NSURLSession,
                    dataTask: NSURLSessionDataTask,
                    didReceiveResponse: NSURLResponse,
                    completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
        if cancelled {
            self.state = .Finished
            task?.cancel()
            return
        }
        
        completionHandler(.Allow)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
        if cancelled {
            self.state = .Finished
            task?.cancel()
            return
        }
        
        self.data.appendData(data)
    }
    
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
                
                // If URL exists, update the entry. If not create new entry, parse and store (using child context).
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
                    story.imageURL = nil
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
