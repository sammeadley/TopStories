//
//  TestableURLSessionDownloadTask.swift
//  TopStories
//
//  Created by Sam Meadley on 25/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import Foundation

class TestableURLSessionDownloadTask: URLSessionDownloadTask {

    var stubDownloadLocation: URL?
    
    fileprivate let urlSession: TestableURLSession
    
    init(urlSession: TestableURLSession) {
        self.urlSession = urlSession
    }
    
    override func resume() {
        
        guard let stubDownloadLocation = stubDownloadLocation else {
            return
        }
        
        guard let delegate = urlSession.delegate as? URLSessionDownloadDelegate else {
            return
        }
        
        delegate.urlSession(urlSession, downloadTask: self, didFinishDownloadingTo: stubDownloadLocation)
    }
    
}
