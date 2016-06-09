//
//  TweetMentionsTableViewController.swift
//  Smashtag
//
//  Created by Michel Deiman on 09/06/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit
import Twitter

private struct Constants {
	static let cellReuseIdentifierForImages = "TweetMediaCell"
	static let cellReuseIdentifierStandard = "TweetMentionsTableViewCell"
	static let SegueToMainTweetTableView = "ToMainTweetTableView"
}

protocol NeedsTweet {
	weak var tweet: Tweet? { get set }
}

class TweetMentionsTableViewController: UITableViewController, NeedsTweet {

	weak var tweet: Tweet?
	
	private enum TweetMention: CustomStringConvertible {
		case Media([MediaItem])
		case Hashtags([Mention])
		case Urls([Mention])
		case UserMentions([Mention])
		
		var count: Int {
			switch self {
			case .Media(let items): return items.count
			case .Hashtags(let items): return items.count
			case .Urls(let items): return items.count
			case .UserMentions(let items): return items.count
			}
		}
		
		var mentions: [Mention] {
			switch self {
			case .Hashtags(let items): return items
			case .Urls(let items): return items
			case .UserMentions(let items): return items
			default: return []
			}
		}
		
		var description: String {
			switch self {
			case .Media: return "Media"
			case .Hashtags: return "Hashtags"
			case .Urls: return "URLs"
			case .UserMentions: return "UserMentions"
			}
		}
	}
	
	
	private var tweetMentions: [TweetMention] = []
	
	override func viewDidLoad() {
        super.viewDidLoad()
		if let tweet = self.tweet {
			if !tweet.media.isEmpty {
				tweetMentions.append(TweetMention.Media(tweet.media))
			}
			if !tweet.hashtags.isEmpty {
				tweetMentions.append(TweetMention.Hashtags(tweet.hashtags))
			}
			if !tweet.urls.isEmpty {
				tweetMentions.append(TweetMention.Urls(tweet.urls))
			}
			if !tweet.userMentions.isEmpty {
				tweetMentions.append(TweetMention.UserMentions(tweet.userMentions))
			}
		}
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweetMentions.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tweetMentions[section].count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let tweetMention = tweetMentions[indexPath.section]
		switch tweetMention {
		case .Media(let items):
			let dequeuedCell = tableView.dequeueReusableCellWithIdentifier(Constants.cellReuseIdentifierForImages, forIndexPath: indexPath)
			if let cell = dequeuedCell as? TweetMediaTableViewCell {
				cell.mediaItem = items[indexPath.row]
			}
			return dequeuedCell
		default:
			let mention = tweetMention.mentions[indexPath.row]
			let cell = tableView.dequeueReusableCellWithIdentifier(Constants.cellReuseIdentifierStandard, forIndexPath: indexPath)
			cell.textLabel?.text = mention.keyword
			return cell
		}
    }

	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return tweetMentions[section].description
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		let tweetMention = tweetMentions[indexPath.section]
		switch tweetMention {
		case .Media(let mediaItems): break
		case .UserMentions, .Hashtags:
			let mentions = tweetMention.mentions
			let keyWord = mentions[indexPath.row].keyword
			recentSearchKeys.addSearchKey(keyWord)
			performSegueWithIdentifier(Constants.SegueToMainTweetTableView, sender: self)
		case .Urls(let mentions):
			let urlString = mentions[indexPath.row].keyword
			if let url = NSURL(string: urlString) {
				UIApplication.sharedApplication().openURL(url)
			}
		}

	}
	
	override func tableView(tableView: UITableView,
	                        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		let tweetMention = tweetMentions[indexPath.section]
		switch tweetMention {
		case .Media(let mediaItems):
			let mediaItem = mediaItems[indexPath.row]
			return tableView.bounds.size.width / CGFloat(mediaItem.aspectRatio)
		default:
			return UITableViewAutomaticDimension
		}
	}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
