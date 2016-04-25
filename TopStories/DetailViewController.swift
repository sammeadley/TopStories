//
//  DetailViewController.swift
//  TopStories
//
//  Created by Sam Meadley on 19/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit
import SafariServices

class DetailViewController: UIViewController {
    
    static let defaultSegueIdentifier = String(DetailViewController)
    
    var story: Story?
    var requestController: RequestController?
    
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var abstractLabel: UILabel?
    @IBOutlet private weak var imageView: UIImageView?
    @IBOutlet private weak var emptyLabel: UILabel?
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        
        guard let story = story else {
            titleLabel?.text = ""
            abstractLabel?.text = ""
            
            emptyLabel?.hidden = false
            self.navigationController?.toolbarHidden = true
            
            return
        }
        
        titleLabel?.text = story.title
        abstractLabel?.text = story.abstract
        
        addObservers()
        
        // Fetching an image from the disk cache can be costly, so do this in a background queue.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            if let story = self.story {
                let image = self.requestController?.requestImageForStory(story)
                dispatch_async(dispatch_get_main_queue()) {
                    self.imageView?.image = image
                }
            }
        }
        
        navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true
        
        super.viewDidLoad()
    }
    
    // MARK: - NSNotificationCenter
    
    func addObservers() {
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(didReceiveImageRequestDidCompleteNotification),
                                                         name: RequestController.Notifications.ImageRequestDidComplete,
                                                         object: Story.ImageSize.Default.rawValue)
    }
    
    func didReceiveImageRequestDidCompleteNotification(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let image = userInfo[RequestController.Notifications.Keys.Image] as? UIImage
        imageView?.image = image
    }
    
}

private extension DetailViewController {
    
    // MARK: - Actions
    
    @IBAction func showArticle(sender: UIBarButtonItem) {
        
        guard let contentURL = story?.contentURL else {
            return
        }
        
        guard let URL = NSURL(string: contentURL) else {
            return
        }
        
        let viewController = SFSafariViewController(URL: URL)
        
        presentViewController(viewController, animated: true, completion: nil)
    }

}