//
//  MasterViewController.swift
//  TopStories
//
//  Created by Sam Meadley on 19/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var requestController: RequestController?
    var fetchedResultsController: NSFetchedResultsController?
    
    var itemChanges: [ NSFetchedResultsChangeType : [AnyObject] ]?
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        collectionView?.collectionViewLayout = StoriesViewControllerLayout()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(didReceiveImageRequestDidCompleteNotification),
                                                         name: RequestController.Notifications.ImageRequestDidComplete,
                                                         object: nil)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        
        fetchedResultsController = requestController?.requestTopStories()
        fetchedResultsController?.delegate = self
        collectionView?.reloadData()
        
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.collectionView?.indexPathsForSelectedItems()?.first {
                let object = self.fetchedResultsController!.objectAtIndexPath(indexPath)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return self.fetchedResultsController?.sections?.count ?? 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController!.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StoryCollectionViewCell.defaultReuseIdentifier,
                                                                         forIndexPath: indexPath) as! StoryCollectionViewCell
        
        let story = self.fetchedResultsController!.objectAtIndexPath(indexPath) as! Story
        cell.updateForStory(story)
        
        // Fetching an image from the disk cache can be costly, so do this in a background queue.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let image = self.requestController?.requestImageForStory(story)
            dispatch_async(dispatch_get_main_queue()) {
                cell.image = image
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
    
}
