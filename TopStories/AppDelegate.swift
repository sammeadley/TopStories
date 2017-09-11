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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        persistenceController = PersistenceController()
        if let managedObjectContext = persistenceController?.managedObjectContext {
            requestController = RequestController(managedObjectContext: managedObjectContext)
        }
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        splitViewController.delegate = self
        
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        navigationController.topViewController!.navigationItem.leftItemsSupplementBackButton = true
        
        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
        let controller = masterNavigationController.topViewController as! StoriesViewController
        controller.managedObjectContext = persistenceController?.managedObjectContext;
        controller.requestController = requestController
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        // Saves changes in the application's managed object context before the application terminates.
        guard let managedObjectContext = self.persistenceController?.managedObjectContext else {
            return;
        }
        
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                
            } catch {
                // TODO: Handle error
            }
        }
    }
}

extension AppDelegate: UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
