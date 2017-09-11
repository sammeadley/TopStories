//
//  TestableURLSession.swift
//  TopStories
//
//  Created by Sam Meadley on 20/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import Foundation

class TestableURLSession: URLSession {

    var stubTask: URLSessionTask?
    
    // Not possible to override init(configuration:delegate:delegateQueue:) so we'll manage
    // the delegate property internally.
    fileprivate var internalDelegate: URLSessionDelegate?
    
    init(delegate: URLSessionDelegate?) {
        self.internalDelegate = delegate
    }
    
    override var delegate: URLSessionDelegate? {
        get {
            return internalDelegate
        }
        set {
            internalDelegate = newValue
        }
    }
    
    override func dataTask(with url: URL) -> URLSessionDataTask {
        // Failing to set dataTask is a programmer error, so we are safe to force unwrap here.
        return stubTask as! TestableURLSessionDataTask
    }
    
    override func downloadTask(with url: URL) -> URLSessionDownloadTask {
        // Failing to set dataTask is a programmer error, so we are safe to force unwrap here.
        return stubTask as! TestableURLSessionDownloadTask
    }
}
