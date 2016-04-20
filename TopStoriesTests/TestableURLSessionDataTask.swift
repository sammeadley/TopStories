//
//  TestableURLSessionDataTask.swift
//  TopStories
//
//  Created by Sam Meadley on 20/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import Foundation

class TestableURLSessionDataTask: NSURLSessionDataTask {

    var stubData: NSData?
    var stubError: NSError?
    
    private let URLSession: TestableURLSession
    
    init(URLSession: TestableURLSession) {
        self.URLSession = URLSession
    }
    
    override func resume() {
        
        guard let data = stubData else {
            return
        }
        
        guard let delegate = URLSession.delegate as? NSURLSessionDataDelegate else {
            return
        }
        
        delegate.URLSession!(URLSession, dataTask: self, didReceiveData: data)
        delegate.URLSession!(URLSession, task: self, didCompleteWithError: stubError)
    }
    
}
