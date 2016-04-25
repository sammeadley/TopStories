//
//  StoryCollectionViewCell.swift
//  TopStories
//
//  Created by Sam Meadley on 21/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit

class StoryCollectionViewCell: UICollectionViewCell {

    static let defaultReuseIdentifier = String(StoryCollectionViewCell)
        
    var image: UIImage? {
        didSet {
            imageView?.image = image
        }
    }
    
    private let defaultImageViewWidth: CGFloat = 75
    
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var imageView: UIImageView?
    @IBOutlet private weak var imageViewWidthConstraint: NSLayoutConstraint?

    func updateForStory(story: Story) {
        
        titleLabel?.text = story.title
        
        if story.imageURLForSize(Story.ImageSize.Thumbnail) == nil {
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
