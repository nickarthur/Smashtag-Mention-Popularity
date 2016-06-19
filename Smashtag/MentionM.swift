//
//  MentionM.swift
//  Smashtag
//
//  Created by Michel Deiman on 19/06/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import Foundation
import CoreData
import Twitter

class MentionM: NSManagedObject {
	
	class func tweetWith(mentionInfo: Mention, inManagedObjectContext context: NSManagedObjectContext) -> MentionM?
	{
		let request = NSFetchRequest(entityName: "MentionM")
		request.predicate = NSPredicate(format: "referees = %@", mentionInfo.keyword)
		let mentions_M = try? context.executeFetchRequest(request)
		if let mentionM = mentions_M?.first as? MentionM {
			let referees = Int(mentionM.referees!) + 1
			mentionM.referees = NSNumber(integer: referees)
			return mentionM
		} else {
			if let mentionM = NSEntityDescription.insertNewObjectForEntityForName("MentionM", inManagedObjectContext: context) as? MentionM
			{	mentionM.keyword = mentionInfo.keyword
				mentionM.referees = NSNumber(integer: 1)
				return mentionM
			}
		}
		return nil 		// non regular exit...
	}
}

