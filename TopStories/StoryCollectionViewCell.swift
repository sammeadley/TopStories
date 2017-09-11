//
//  StoryCollectionViewCell.swift
//  TopStories
//
//  Created by Sam Meadley on 21/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit

class StoryCollectionViewCell: UICollectionViewCell {

    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
        
    var image: UIImage? {
        didSet {
            imageView?.image = image
        }
    }
    
    fileprivate let defaultImageViewWidth: CGFloat = 75
    
    @IBOutlet fileprivate weak var titleLabel: UILabel?
    @IBOutlet fileprivate weak var imageView: UIImageView?
    @IBOutlet fileprivate weak var imageViewWidthConstraint: NSLayoutConstraint?

    func updateForStory(_ story: Story) {
        
        titleLabel?.text = story.title
        
        if story.imageURL(for: Story.ImageSize.thumbnail) == nil {
            imageViewWidthConstraint?.constant = 0
        } else {
            imageViewWidthConstraint?.constant = defaultImageViewWidth
        }
    }
    
    // MARK: - UICollectionViewCell
    
    override func prepareForReuse() {
        imageView?.image = nil
        
        super.prepareForReuse()
    }
}
