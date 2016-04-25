//
//  TestableURLSession.swift
//  TopStories
//
//  Created by Sam Meadley on 20/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import Foundation

class TestableURLSession: NSURLSession {

    var stubTask: NSURLSessionTask?
    
    // Not possible to override init(configuration:delegate:delegateQueue:) so we'll manage
    // the delegate property internally.
    private var internalDelegate: NSURLSessionDelegate?
    
    init(delegate: NSURLSessionDelegate?) {
        self.internalDelegate = delegate
    }
    
    override var delegate: NSURLSessionDelegate? {
        get {
            return internalDelegate
        }
        set {
            internalDelegate = newValue
        }
    }
    
    override func dataTaskWithURL(url: NSURL) -> NSURLSessionDataTask {
        // Failing to set dataTask is a programmer error, so we are safe to force unwrap here.
        return stubTask as! TestableURLSessionDataTask
    }
    
    override func downloadTaskWithURL(url: NSURL) -> NSURLSessionDownloadTask {
        // Failing to set dataTask is a programmer error, so we are safe to force unwrap here.
        return stubTask as! TestableURLSessionDownloadTask
    }
}
