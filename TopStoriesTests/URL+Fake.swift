//
//  URL+Fake.swift
//  TopStories
//
//  Created by Sam Meadley on 10/09/2017.
//  Copyright © 2017 Sam Meadley. All rights reserved.
//

import Foundation

extension URL {
    
    /// Returns a fake URL instance.
    static var fake: URL {
        return URL(string: "nytimes.com")!
    }
}
