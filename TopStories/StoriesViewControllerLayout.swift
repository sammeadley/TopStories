//
//  StoriesViewControllerLayout.swift
//  TopStories
//
//  Created by Sam Meadley on 21/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit

class StoriesViewControllerLayout: UICollectionViewFlowLayout {

    private let defaultItemHeight: CGFloat = 300
    private var bounds = CGRect.zero
    
    override func prepareLayout() {
        
        let itemSize = CGSize(width: (collectionView?.bounds.width)!, height: defaultItemHeight)
        self.itemSize = itemSize
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        
        if CGRectEqualToRect(bounds, newBounds) {
            return false
        }
        
        bounds = newBounds
        
        let itemSize = CGSize(width: newBounds.width, height: defaultItemHeight)
        self.itemSize = itemSize
        
        return true
    }
}
