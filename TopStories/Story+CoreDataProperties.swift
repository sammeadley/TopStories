//
//  Story+CoreDataProperties.swift
//  TopStories
//
//  Created by Sam Meadley on 20/04/2016.
//  Copyright © 2016 Sam Meadley. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Story {

    @NSManaged var title: String?
    @NSManaged var abstract: String?
    @NSManaged var contentURL: String?
    @NSManaged var publishedDate: NSDate?
    @NSManaged var imageURL: String?

}
