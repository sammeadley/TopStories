//
//  StoriesViewController.swift
//  TopStories
//
//  Created by Sam Meadley on 19/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit
import CoreData

final class StoriesViewController: UICollectionViewController {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var requestController: RequestController?
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    fileprivate var itemChanges: [NSFetchedResultsChangeType: [Any]]?
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.collectionViewLayout = StoriesViewControllerLayout()
        
        fetchedResultsController = requestController?.requestTopStories()
        fetchedResultsController?.delegate = self
        collectionView?.reloadData()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        collectionView?.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        clearsSelectionOnViewWillAppear = splitViewController?.isCollapsed ?? true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == DetailViewController.defaultSegueIdentifier {
            
            guard let indexPath = collectionView?.indexPathsForSelectedItems?.first else {
                return
            }
            
            let story = fetchedResultsController?.object(at: indexPath) as! Story
            let navigationController = segue.destination as! UINavigationController
            let viewController = navigationController.topViewController as! DetailViewController
            viewController.story = story
            viewController.requestController = requestController
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController?.sections?[section]
        
        return sectionInfo?.numberOfObjects ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCollectionViewCell.defaultReuseIdentifier,
                                                          for: indexPath) as? StoryCollectionViewCell,
            let story = fetchedResultsController?.object(at: indexPath) as? Story else {
                fatalError()
        }
        
        cell.updateForStory(story)
        
        // Fetching an image from the disk cache can be costly, so do this in a background queue.
        DispatchQueue.global(qos: .default).async {
            let image = self.requestController?.requestImage(for: story,
                                                             imageSize: .thumbnail,
                                                             observer: self,
                                                             selector: #selector(self.imageRequestDidComplete(_:)))
            DispatchQueue.main.async {
                cell.image = image
            }
        }
        
        return cell
    }
}

// MARK: - Actions
private extension StoriesViewController {
    
    @objc dynamic func refresh(_ refreshControl: UIRefreshControl) {
        
        requestController?.requestTopStories()
        refreshControl.endRefreshing()
    }
}

// MARK: - Notifications
private extension StoriesViewController {
    
    @objc dynamic func imageRequestDidComplete(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo else {
            return
        }
        
        let image = userInfo[ImageRequestDidCompleteUserInfoKeys.image] as? UIImage
        let story = userInfo[ImageRequestDidCompleteUserInfoKeys.story] as? Story
        
        if let index = fetchedResultsController?.fetchedObjects?.index(where: { $0 as? Story == story }) {
            
            // Collection view just has a single section, so we're OK to hard code this for now...
            let indexPath = IndexPath(item: index, section: 0)
            if collectionView!.indexPathsForVisibleItems.contains(indexPath) {
                
                let cell = collectionView?.cellForItem(at: indexPath) as? StoryCollectionViewCell
                cell?.image = image
            }
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension StoriesViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        itemChanges = [ .insert : [],
                        .delete : [],
                        .update : [],
                        .move : [] ]
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                itemChanges?[type]?.append(newIndexPath)
            }
            
        case .delete:
            if let indexPath = indexPath {
                itemChanges?[type]?.append(indexPath)
            }
            
        case .update:
            if let indexPath = indexPath {
                itemChanges?[type]?.append(indexPath)
            }
            
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                itemChanges?[type]?.append(contentsOf: [indexPath, newIndexPath])
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView?.performBatchUpdates({
            
            if let deletedIndexPaths = self.itemChanges?[.delete] as? [IndexPath] {
                self.collectionView?.deleteItems(at: deletedIndexPaths)
            }
            
            if let insertedIndexPaths = self.itemChanges?[.insert] as? [IndexPath] {
                self.collectionView?.insertItems(at: insertedIndexPaths)
            }
            
            if let updatedIndexPaths = self.itemChanges?[.update] as? [IndexPath] {
                self.collectionView?.reloadItems(at: updatedIndexPaths)
            }
            
            if let movedIndexPaths = self.itemChanges?[.move] as? [ [IndexPath] ] {
                for indexPaths in movedIndexPaths {
                    self.collectionView?.moveItem(at: indexPaths[0], to: indexPaths[1])
                }
            }
            
        }, completion: { finished in
            
            self.itemChanges = nil
        })
    }
}
