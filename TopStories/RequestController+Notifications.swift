//
//  RequestController+Notifications.swift
//  TopStories
//
//  Created by Sam Meadley on 10/09/2017.
//  Copyright © 2017 Sam Meadley. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let imageRequestDidComplete = Notification.Name("com.sammeadley.TopStories.imageRequestDidComplete")
}

enum ImageRequestDidCompleteUserInfoKeys {
    static let image = "image"
    static let story = "story"
}
