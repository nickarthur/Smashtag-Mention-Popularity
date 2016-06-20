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
	@NSManaged var mentioned: NSSet
	@NSManaged var tweets: NSSet
}

class MentionM: NSManagedObject {
	
	class func tweetWith(mentionInfo: Mention, forSearchTerm key: String, inManagedObjectContext context: NSManagedObjectContext) -> MentionM?
	{
		let request = NSFetchRequest(entityName: "MentionM")
		request.predicate = NSPredicate(format: "keyword LIKE[cd] %@", mentionInfo.keyword)
		if let mentionM = (try? context.executeFetchRequest(request))?.first as? MentionM
		{
			let request = NSFetchRequest(entityName: "SearchTerm")
			request.predicate = NSPredicate(format: "keyword LIKE[cd] %@ AND mention == %@", key, mentionM)
			if let searchM = (try? context.executeFetchRequest(request))?.first as? SearchTerm {
				searchM.count = searchM.count.integerValue + 1
				print("SearchTerm found...")
			} else {
				print("!!!!!SearchTerm not found.!!!!!!! for mention: ", mentionM.keyword, "key: ", key)
				// create one anyway? no ..! An instance is created together with MentionM
				if let searchM = SearchTerm.statisticsFor(key, mention: mentionM, inManagedObjectContext: context) {
					let mentioned = mentionM.mutableSetValueForKey("mentioned")
					mentioned.addObject(searchM)
				}

			}
			return mentionM
		} else {
			if let mentionM = NSEntityDescription.insertNewObjectForEntityForName("MentionM", inManagedObjectContext: context) as? MentionM
			{
				mentionM.keyword = mentionInfo.keyword
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
