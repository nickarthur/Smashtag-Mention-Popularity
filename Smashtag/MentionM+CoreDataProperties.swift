//
//  MentionM+CoreDataProperties.swift
//  Smashtag
//
//  Created by Michel Deiman on 19/06/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension MentionM {

    @NSManaged var referees: NSNumber?
    @NSManaged var keyword: String?
    @NSManaged var tweets: NSSet

}
