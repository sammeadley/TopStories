//
//  TestableFileManager.swift
//  TopStories
//
//  Created by Sam Meadley on 24/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import Foundation

class TestableFileManager: FileManager {

    fileprivate(set) var destinationOfMovedItem: URL?
    var stubFileExistsAtPath: Bool?
    var stubContentsAtPath: Data?
    
    override func fileExists(atPath path: String) -> Bool {
        
        guard let stubFileExistsAtPath = stubFileExistsAtPath else {
            return super.fileExists(atPath: path)
        }
        
        return stubFileExistsAtPath
    }
    
    // We don't want the stub subclass to affect the file system, so we don't call super.
    override func moveItem(at srcURL: URL, to dstURL: URL) throws {
        destinationOfMovedItem = dstURL
    }
    
    override func contents(atPath path: String) -> Data? {
        
        guard let stubContentsAtPath = stubContentsAtPath else {
            return super.contents(atPath: path)
        }
        
        return stubContentsAtPath
    }
}
