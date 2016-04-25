//
//  NetworkRequest.swift
//  TopStories
//
//  Created by Sam Meadley on 21/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import Foundation

class NetworkRequest: NSOperation, NSURLSessionDataDelegate {
    
    var error: NetworkRequestError?
    
    internal var task: NSURLSessionTask?
    internal let data = NSMutableData()
    
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
    
    internal var state = State.Ready {
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
    
    // MARK: - NSURLSessionDataDelegate
    
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
    
}

// MARK:- Error Types

enum NetworkRequestError: ErrorType {
    case InvalidURL
    case NetworkError(NSError?)
    case ClientError(String, NSError?)
}
