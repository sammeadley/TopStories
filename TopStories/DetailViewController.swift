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
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        
        self.titleLabel?.text = story?.title
        self.abstractLabel?.text = story?.abstract
        
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