//
//  AppDelegate.swift
//  TopStories
//
//  Created by Sam Meadley on 19/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var persistenceController: PersistenceController?
    var requestController: RequestController?
    
    // MARK: - UIApplicationDelegate
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        persistenceController = PersistenceController()
        if let managedObjectContext = persistenceController?.managedObjectContext {
            requestController = RequestController(managedObjectContext: managedObjectContext)
        }
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        splitViewController.delegate = self
        
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        navigationController.topViewController!.navigationItem.leftItemsSupplementBackButton = true

        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
        let controller = masterNavigationController.topViewController as! MasterViewController
        controller.managedObjectContext = persistenceController?.managedObjectContext;
        controller.requestController = requestController
        
        return true
    }
    
    func applicationWillTerminate(application: UIApplication) {

        // Saves changes in the application's managed object context before the application terminates.
        guard let managedObjectContext = self.persistenceController?.managedObjectContext else {
            return;
        }
        
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                
            } catch {
                
                // TODO: Remove this temporary NSLog and report error to Framework/Server.
                let error = error as NSError
                NSLog("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}

extension AppDelegate: UISplitViewControllerDelegate {
    
    func splitViewController(splitViewController: UISplitViewController,
                             collapseSecondaryViewController secondaryViewController: UIViewController,
                                                             ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return true
    }
}
