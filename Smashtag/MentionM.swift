//
//  MentionM.swift
//  Smashtag
//
//  Created by Michel Deiman on 20/06/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import Foundation
import CoreData
import Twitter

extension MentionM {
	
	@NSManaged var keyword: String
	@NSManaged var type: String
	@NSManaged var mentioned: NSSet
	@NSManaged var tweets: NSSet
}

class MentionM: NSManagedObject {
	
	class func tweetWith(mentionInfo: Mention, mentionType: String, forSearchTerm key: String, inManagedObjectContext context: NSManagedObjectContext) -> MentionM?
	{
		let request = NSFetchRequest(entityName: "MentionM")
		request.predicate = NSPredicate(format: "keyword LIKE[cd] %@", mentionInfo.keyword)
		if let mentionM = (try? context.executeFetchRequest(request))?.first as? MentionM
		{
			let request = NSFetchRequest(entityName: "SearchTerm")
			request.predicate = NSPredicate(format: "keyword LIKE[cd] %@ AND mention == %@", key, mentionM)
			if let searchM = (try? context.executeFetchRequest(request))?.first as? SearchTerm {
				searchM.count = searchM.count.integerValue + 1
			} else
			{	if let searchM = SearchTerm.statisticsFor(key, mention: mentionM, inManagedObjectContext: context) {
					let mentioned = mentionM.mutableSetValueForKey("mentioned")
					mentioned.addObject(searchM)
				}

			}
			return mentionM
		} else {
			if let mentionM = NSEntityDescription.insertNewObjectForEntityForName("MentionM", inManagedObjectContext: context) as? MentionM
			{
				mentionM.keyword = mentionInfo.keyword
				mentionM.type = mentionType
//				mentionM.type = mentionInfo.keyword.hasPrefix("#") ? 1 : 0
				if let searchM = SearchTerm.statisticsFor(key, mention: mentionM, inManagedObjectContext: context) {
					let mentioned = mentionM.mutableSetValueForKey("mentioned")
					mentioned.addObject(searchM)
				}
				return mentionM
			}
		}
		return nil 		// non regular exit...
	}
}
