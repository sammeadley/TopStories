//
//  TestableURLSessionDataTask.swift
//  TopStories
//
//  Created by Sam Meadley on 20/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import Foundation

class TestableURLSessionDataTask: URLSessionDataTask {

    var stubData: Data?
    var stubError: NSError?
    
    fileprivate let urlSession: TestableURLSession
    
    init(urlSession: TestableURLSession) {
        self.urlSession = urlSession
    }
    
    override func resume() {
        
        guard let data = stubData else {
            return
        }
        
        guard let delegate = urlSession.delegate as? URLSessionDataDelegate else {
            return
        }
        
        delegate.urlSession!(urlSession, dataTask: self, didReceive: data)
        delegate.urlSession!(urlSession, task: self, didCompleteWithError: stubError)
    }
    
}
