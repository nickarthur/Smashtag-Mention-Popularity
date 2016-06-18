//
//  Tweet+CoreDataProperties.swift
//  Smashtag
//
//  Created by Michel Deiman on 18/06/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Tweet {

    @NSManaged var created: NSDate?
    @NSManaged var id: String?
    @NSManaged var text: String?
    @NSManaged var tweeter: TwitterUser?

}
