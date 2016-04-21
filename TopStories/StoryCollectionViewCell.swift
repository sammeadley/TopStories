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
    
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var abstractLabel: UILabel?
    @IBOutlet private weak var imageView: UIImageView?

    func updateForStory(story: Story) {
        
        titleLabel?.text = story.title
        abstractLabel?.text = story.abstract
    }
}
