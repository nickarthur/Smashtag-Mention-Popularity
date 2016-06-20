//
//  TweetM.swift
//  Smashtag
//
//  Created by Michel Deiman on 19/06/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import Foundation
import CoreData
import Twitter

extension TweetM {
	
	@NSManaged var created: NSDate?
	@NSManaged var id: String?
	@NSManaged var text: String?
	@NSManaged var tweeter: UserM?
	@NSManaged var mentions: NSSet
}

class TweetM: NSManagedObject {

	class func tweetWith(twitterInfo: Tweet, forSearchTerm key: String, inManagedObjectContext context: NSManagedObjectContext) -> TweetM?
	{
		let request = NSFetchRequest(entityName: "TweetM")
		request.predicate = NSPredicate(format: "id = %@", twitterInfo.id)
		let tweetsM = try? context.executeFetchRequest(request)
		if let tweetM = tweetsM?.first as? TweetM {
			return tweetM
		} else {
			if let tweetM = NSEntityDescription.insertNewObjectForEntityForName("TweetM", inManagedObjectContext: context) as? TweetM
			{	tweetM.id = twitterInfo.id
				tweetM.text = twitterInfo.text
				tweetM.created = twitterInfo.created
				tweetM.tweeter = UserM.twitterUserWith(twitterInfo.user, inManagedObjectContext: context)
				
				let twitterMentions = twitterInfo.hashtags + twitterInfo.userMentions
				for mention in twitterMentions {
					if let mentionM = MentionM.tweetWith(mention, forSearchTerm: key, inManagedObjectContext: context) {
						let mentions = tweetM.mutableSetValueForKey("mentions")
						mentions.addObject(mentionM)
					}
				}
				return tweetM
			}
		}
		return nil 		// non regular exit...
	}
	
	
}



