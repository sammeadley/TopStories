//
//  ImageRequest.swift
//  TopStories
//
//  Created by Sam Meadley on 21/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit

class ImageRequest: NetworkRequest, NSURLSessionDownloadDelegate {
    
    var URLSession: NSURLSession?
    
    private let story: Story
    private let cache: ImageCache
    private let imageSize: Story.ImageSize
    private let imageURL: String
    
    /**
     Initializes the request with dependencies.
     
     - parameter story: The story with the image to load.
     - parameter cache: The imageCache instance to check for membership.
     - parameter imageSize: The image size to download, see Story.ImageSize for possible values.
     */
    init(story: Story, cache: ImageCache, imageSize: Story.ImageSize) {
        self.story = story
        self.cache = cache
        self.imageSize = imageSize
        self.imageURL = story.imageURLForSize(imageSize)!
        
        super.init()
        self.queuePriority = .Low
        self.qualityOfService = .Utility
    }
    
    // MARK: - NSOperation
    
    override func start() {
        
        guard let URL = NSURL(string: imageURL) else {
            self.error = .InvalidURL
            self.state = .Finished
            return
        }
        
        if (URLSession == nil) {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            URLSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        }
        
        task = URLSession?.downloadTaskWithURL(URL)
        task?.resume()
    }
    
    // MARK: - NSURLSessionDownloadDelegate
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        if error != nil {
            self.error = .NetworkError(error)
            self.state = .Finished
            return
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        if cancelled {
            self.state = .Finished
            return
        }
        
        guard let data = NSData(contentsOfURL: location) else {
            
            self.error = .ClientError(NSLocalizedString("Failed to read image data", comment: ""), nil)
            self.state = .Finished
            return
        }
        
        guard let image = UIImage(data: data)?.decompress() else {
            
            self.error = .ClientError(NSLocalizedString("Failed to build image from data", comment: ""), nil)
            self.state = .Finished
            return
        }
        
        cache.setImage(image, forURL: imageURL, temporaryFileURL: location)
        
        dispatch_async(dispatch_get_main_queue(), {
            NSNotificationCenter.defaultCenter().postNotificationName(RequestController.Notifications.ImageRequestDidComplete,
                object: self.imageSize.rawValue, // Pass imageSize allowing observers to filter notifications they receive.
                userInfo: [
                    RequestController.Notifications.Keys.Image : image,
                    RequestController.Notifications.Keys.Story : self.story])
            })
        
        self.state = .Finished
    }
    
    // MARK: - NSObject
    
    override func isEqual(object: AnyObject?) -> Bool {
        
        if let object = object as? ImageRequest {
            return imageURL == object.imageURL
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return imageURL.hashValue
    }
    
}
