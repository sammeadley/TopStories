//
//  NetworkRequest.swift
//  TopStories
//
//  Created by Sam Meadley on 21/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import Foundation

class NetworkRequest: Operation, URLSessionDataDelegate {
    
    var error: NetworkRequestError?
    
    internal var task: URLSessionTask?
    internal let data = NSMutableData()
    
    // MARK: - Types
    
    enum State {
        case ready, executing, finished
        func keyPath() -> String {
            switch self {
            case .ready:
                return "isReady"
            case .executing:
                return "isExecuting"
            case .finished:
                return "isFinished"
            }
        }
    }
    
    // MARK: - Properties
    
    internal var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath())
            willChangeValue(forKey: state.keyPath())
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath())
            didChangeValue(forKey: state.keyPath())
        }
    }
    
    // MARK: - NSOperation
    
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    // MARK: - NSURLSessionDataDelegate
    
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive didReceiveResponse: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        if isCancelled {
            state = .finished
            task?.cancel()
            return
        }
        
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        if isCancelled {
            state = .finished
            task?.cancel()
            return
        }
        
        self.data.append(data)
    }
    
}

// MARK:- Error Types

enum NetworkRequestError: Error {
    case invalidURL
    case networkError(Error?)
    case clientError(String, Error?)
}
