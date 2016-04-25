//
//  TestableURLSessionDownloadTask.swift
//  TopStories
//
//  Created by Sam Meadley on 25/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import Foundation

class TestableURLSessionDownloadTask: NSURLSessionDownloadTask {

    var stubDownloadLocation: NSURL?
    
    private let URLSession: TestableURLSession
    
    init(URLSession: TestableURLSession) {
        self.URLSession = URLSession
    }
    
    override func resume() {
        
        guard let stubDownloadLocation = stubDownloadLocation else {
            return
        }
        
        guard let delegate = URLSession.delegate as? NSURLSessionDownloadDelegate else {
            return
        }
        
        delegate.URLSession(URLSession, downloadTask: self, didFinishDownloadingToURL: stubDownloadLocation)
    }
    
}
