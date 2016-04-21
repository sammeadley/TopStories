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
    
    func configureCell(cell: UICollectionViewCell, withObject object: NSManagedObject) {
        // TODO: Complete implementation.
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        fetchedResultsController = requestController?.requestTopStories()
        fetchedResultsController?.delegate = self
        collectionView?.reloadData()
        
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UICollectionViewCell", forIndexPath: indexPath)
        let object = self.fetchedResultsController!.objectAtIndexPath(indexPath) as! NSManagedObject
        self.configureCell(cell, withObject: object)
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
    
}
