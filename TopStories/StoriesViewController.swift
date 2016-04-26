//
//  StoriesViewController.swift
//  TopStories
//
//  Created by Sam Meadley on 19/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit
import CoreData

class StoriesViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var requestController: RequestController?
    
    private var fetchedResultsController: NSFetchedResultsController?
    private var itemChanges: [ NSFetchedResultsChangeType : [AnyObject] ]?
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        collectionView?.collectionViewLayout = StoriesViewControllerLayout()
        
        fetchedResultsController = requestController?.requestTopStories()
        fetchedResultsController?.delegate = self
        collectionView?.reloadData()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action: #selector(refresh),
                                 forControlEvents: .ValueChanged)
        collectionView?.addSubview(refreshControl)
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == DetailViewController.defaultSegueIdentifier {
            
            guard let indexPath = self.collectionView?.indexPathsForSelectedItems()?.first else {
                return
            }
            
            let story = fetchedResultsController?.objectAtIndexPath(indexPath) as! Story
            let navigationController = segue.destinationViewController as! UINavigationController
            let viewController = navigationController.topViewController as! DetailViewController            
            viewController.story = story
            viewController.requestController = requestController
        }
    }

    // MARK: - UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return self.fetchedResultsController?.sections?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController?.sections?[section]
        
        return sectionInfo?.numberOfObjects ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StoryCollectionViewCell.defaultReuseIdentifier,
                                                                         forIndexPath: indexPath) as! StoryCollectionViewCell
        
        let story = self.fetchedResultsController!.objectAtIndexPath(indexPath) as! Story
        cell.updateForStory(story)
        
        // Fetching an image from the disk cache can be costly, so do this in a background queue.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let image = self.requestController?.requestImageForStory(story,
                                                                     imageSize: .Thumbnail,
                                                                     observer: self,
                                                                     selector: #selector(self.didReceiveImageRequestDidCompleteNotification))
            dispatch_async(dispatch_get_main_queue()) {
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? StoryCollectionViewCell {
                    cell.image = image
                }
            }
        }
        
        return cell
    }
    
    // MARK: - UIFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        itemChanges = [ .Insert : [],
                        .Delete : [],
                        .Update : [],
                        .Move : [] ]
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            itemChanges![type]?.append(newIndexPath!)
            break
            
        case .Delete:
            itemChanges![type]?.append(indexPath!)
            break
            
        case .Update:
            itemChanges![type]?.append(indexPath!)
            break
            
        case .Move:
            itemChanges![type]?.append( NSArray(objects: indexPath!, newIndexPath!) )
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        collectionView?.performBatchUpdates({
            
            if let deletedIndexPaths = self.itemChanges![.Delete] as? [NSIndexPath] {
                self.collectionView?.deleteItemsAtIndexPaths(deletedIndexPaths)
            }
            
            if let insertedIndexPaths = self.itemChanges![.Insert] as? [NSIndexPath] {
                self.collectionView?.insertItemsAtIndexPaths(insertedIndexPaths)
            }
            
            if let updatedIndexPaths = self.itemChanges![.Update] as? [NSIndexPath] {
                self.collectionView?.reloadItemsAtIndexPaths(updatedIndexPaths)
            }
            
            if let movedIndexPaths = self.itemChanges![.Move] as? [ [NSIndexPath] ] {
                for indexPaths in movedIndexPaths {
                    self.collectionView?.moveItemAtIndexPath(indexPaths[0], toIndexPath: indexPaths[1])
                }
            }
            
            }, completion: { finished in
                
                self.itemChanges = nil
        })
    }
    
    // MARK: - Actions
    
    func didReceiveImageRequestDidCompleteNotification(notification: NSNotification) {

        guard let userInfo = notification.userInfo else {
            return
        }
        
        let image = userInfo[RequestController.Notifications.Keys.Image] as? UIImage
        let story = userInfo[RequestController.Notifications.Keys.Story] as? Story
        
        if let index = fetchedResultsController?.fetchedObjects?.indexOf({ $0 as? Story == story }) {

            // Collection view just has a single section, so we're OK to hard code this for now...
            let indexPath = NSIndexPath(forItem: index, inSection: 0)
            if collectionView!.indexPathsForVisibleItems().contains(indexPath) {
            
                let cell = collectionView?.cellForItemAtIndexPath(indexPath) as? StoryCollectionViewCell
                cell?.image = image
            }
        }
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        
        requestController?.requestTopStories()
        refreshControl.endRefreshing()
    }
}
