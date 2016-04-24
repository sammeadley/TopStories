//
//  TestableFileManager.swift
//  TopStories
//
//  Created by Sam Meadley on 24/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import Foundation

class TestableFileManager: NSFileManager {

    private(set) var destinationOfMovedItem: NSURL?
    var stubFileExistsAtPath: Bool?
    
    override func fileExistsAtPath(path: String) -> Bool {
        
        guard let stubFileExistsAtPath = stubFileExistsAtPath else {
            return super.fileExistsAtPath(path)
        }
        
        return stubFileExistsAtPath
    }
    
    // We don't want the stub subclass to affect the file system, so we don't call super.
    override func moveItemAtURL(srcURL: NSURL, toURL dstURL: NSURL) throws {
        destinationOfMovedItem = dstURL
    }
}
