//
//  TestableURLSession.swift
//  TopStories
//
//  Created by Sam Meadley on 20/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import Foundation

class TestableURLSession: NSURLSession {

    var stubDataTask: TestableURLSessionDataTask?
    
    // Not possible to override init(configuration:delegate:delegateQueue:) so we'll manage
    // the delegate property internally.
    private var internalDelegate: NSURLSessionDelegate?
    
    init(delegate: NSURLSessionDelegate) {
        self.internalDelegate = delegate
    }
    
    override var delegate: NSURLSessionDelegate? {
        get {
            return internalDelegate
        }
        set (newDelegate) {
            internalDelegate = newDelegate
        }
    }
    
    override func dataTaskWithURL(url: NSURL) -> NSURLSessionDataTask {
        // Failing to set stubDataTask is a programmer error, so we are safe to force unwrap here.
        return stubDataTask!
    }
    
}
