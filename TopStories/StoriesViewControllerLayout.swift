//
//  StoriesViewControllerLayout.swift
//  TopStories
//
//  Created by Sam Meadley on 21/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit

class StoriesViewControllerLayout: UICollectionViewFlowLayout {

    fileprivate let defaultItemHeight: CGFloat = 75
    fileprivate var bounds = CGRect.zero
    
    override func prepare() {
        
        itemSize = CGSize(width: (collectionView?.bounds.width)!, height: defaultItemHeight)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        
        if bounds.equalTo(newBounds) {
            return false
        }
        
        bounds = newBounds
        
        itemSize = CGSize(width: newBounds.width, height: defaultItemHeight)
        
        return true
    }
}
