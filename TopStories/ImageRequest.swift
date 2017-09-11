//
//  ImageRequest.swift
//  TopStories
//
//  Created by Sam Meadley on 21/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit

class ImageRequest: NetworkRequest, URLSessionDownloadDelegate {
    
    var urlSession: URLSession?
    
    fileprivate let story: Story
    fileprivate let cache: ImageCache
    fileprivate let imageSize: Story.ImageSize
    fileprivate let imageURL: String
    
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
        self.imageURL = story.imageURL(for: imageSize)!
        
        super.init()
        self.queuePriority = .low
        self.qualityOfService = .utility
    }
    
    // MARK: - NSOperation
    
    override func start() {
        
        guard let url = URL(string: imageURL) else {
            error = .invalidURL
            state = .finished
            return
        }
        
        if (urlSession == nil) {
            let configuration = URLSessionConfiguration.default
            urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        }
        
        task = urlSession?.downloadTask(with: url)
        task?.resume()
    }
    
    // MARK: - NSURLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if error != nil {
            self.error = .networkError(error)
            state = .finished
            return
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        if isCancelled {
            state = .finished
            return
        }
        
        guard let data = try? Data(contentsOf: location) else {
            
            error = .clientError(NSLocalizedString("Failed to read image data", comment: ""), nil)
            state = .finished
            return
        }
        
        guard let image = UIImage(data: data)?.decompress() else {
            
            error = .clientError(NSLocalizedString("Failed to build image from data", comment: ""), nil)
            state = .finished
            return
        }
        
        cache.setImage(image, forURL: imageURL, temporaryFileURL: location)
        
        DispatchQueue.main.async(execute: {
            NotificationCenter.default.post(name: .imageRequestDidComplete,
                                            object: self,
                                            userInfo: [ImageRequestDidCompleteUserInfoKeys.image: image,
                                                       ImageRequestDidCompleteUserInfoKeys.story: self.story])
        })
        
        state = .finished
    }
    
    // MARK: - NSObject
    
    override func isEqual(_ object: Any?) -> Bool {
        
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
