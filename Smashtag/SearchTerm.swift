//
//  SearchTerm.swift
//  Smashtag
//
//  Created by Michel Deiman on 20/06/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import Foundation
import CoreData
import Twitter

extension SearchTerm {
	@NSManaged var count: NSNumber
	@NSManaged var keyword: String
	@NSManaged var mention: MentionM
}


class SearchTerm: NSManagedObject
{
	class func statisticsFor(keyword: String, mention: MentionM, inManagedObjectContext context: NSManagedObjectContext) -> SearchTerm?
	{
		if let searchM = NSEntityDescription.insertNewObjectForEntityForName("SearchTerm", inManagedObjectContext: context) as? SearchTerm {
			searchM.count = 1
			searchM.keyword = keyword
			searchM.mention = mention
			return searchM
		}
		print("return nil...!!!!!!!!!!")
		return nil
	}

	
}
