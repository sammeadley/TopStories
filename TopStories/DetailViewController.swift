//
//  DetailViewController.swift
//  TopStories
//
//  Created by Sam Meadley on 19/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit
import SafariServices

final class DetailViewController: UIViewController {
    
    static var defaultSegueIdentifier: String {
        return String(describing: self)
    }
    
    var requestController: RequestController?
    var story: Story?
    
    @IBOutlet fileprivate weak var imageView: UIImageView?
    
    @IBOutlet private weak var abstractLabel: UILabel?
    @IBOutlet private weak var emptyLabel: UILabel?
    @IBOutlet private weak var titleLabel: UILabel?
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let story = story else {
            titleLabel?.text = ""
            abstractLabel?.text = ""
            
            emptyLabel?.isHidden = false
            self.navigationController?.isToolbarHidden = true
            
            return
        }
        
        titleLabel?.text = story.title
        abstractLabel?.text = story.abstract
        
        // Fetching an image from the disk cache can be costly, so do this in a background queue.
        DispatchQueue.global(qos: .default).async {
            
            if let story = self.story {
                let image = self.requestController?.requestImage(for: story,
                                                                 imageSize: .default,
                                                                 observer: self,
                                                                 selector: #selector(self.imageRequestDidComplete(_:)))
                DispatchQueue.main.async {
                    self.imageView?.image = image
                }
            }
        }
        
        navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
    }
}

// MARK: - Actions
private extension DetailViewController {
    
    @IBAction func showArticle(_ sender: UIBarButtonItem) {
        
        guard let contentURL = story?.contentURL else {
            return
        }
        
        guard let url = URL(string: contentURL) else {
            return
        }
        
        let viewController = SFSafariViewController(url: url)
        
        present(viewController, animated: true, completion: nil)
    }
}

// MARK: - Notifications
private extension DetailViewController {

    @objc dynamic func imageRequestDidComplete(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let image = userInfo[ImageRequestDidCompleteUserInfoKeys.image] as? UIImage
        imageView?.image = image
    }
}
