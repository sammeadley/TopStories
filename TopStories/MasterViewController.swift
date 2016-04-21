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
    
    func configureCell(cell: UICollectionViewCell, withObject object: NSManagedObject) {
        // TODO: Complete implementation.
    }
    
    // MARK: - UIViewController

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        fetchedResultsController = requestController?.requestTopStories()
        fetchedResultsController?.delegate = self
        
        super.viewDidAppear(animated)
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
        
        if fetchedResultsController == nil {
            return 0
        }
        
        return self.fetchedResultsController!.sections?.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if fetchedResultsController == nil {
            return 0
        }
        
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
        
        // TODO: Implement
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        // TODO: Implement
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        // TODO: Implement
    }

}

