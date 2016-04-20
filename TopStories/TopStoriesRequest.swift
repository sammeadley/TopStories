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
    private let managedObjectContext: NSManagedObjectContext?
    private let URL: NSURL
    
    init(managedObjectContext: NSManagedObjectContext?, URL: NSURL) {
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
            
        } catch {
            
        }
        
        self.state = .Finished
    }

}
