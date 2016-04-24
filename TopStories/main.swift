//
//  main.swift
//  TopStories
//
//  Created by Sam Meadley on 24/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit

/**
 The App Delegate class name.
 
 Gets the App Delegate class name, or nil if the bundle has linked the XCTest framework.
 This makes our unit tests faster as it avoids setting up unnecessary UI work.
 
 Adapted from http://qualitycoding.org/app-delegate-for-tests/
 
 - returns: Class name for Application Delegate (AppDelegate) or nil. 
 */
private func delegateClassName() -> String? {
    return NSClassFromString("XCTestCase") == nil ? NSStringFromClass(AppDelegate) : nil
}

UIApplicationMain(Process.argc, Process.unsafeArgv, nil, delegateClassName())