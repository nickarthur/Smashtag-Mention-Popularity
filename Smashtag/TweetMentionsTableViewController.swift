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
	static let SegueToImageView = "ToImageView"
}

protocol NeedsTweet {
	weak var tweet: Tweet? { get set }
}

@objc protocol BridgeMentionAndUser {
	var keywordOrScreenName: String { get }
}

extension Mention: BridgeMentionAndUser {
	var keywordOrScreenName: String {
		return keyword
	}
}

extension User: BridgeMentionAndUser {
	var keywordOrScreenName: String {
		return "@" + screenName
	}
}

class TweetMentionsTableViewController: UITableViewController, NeedsTweet {

	weak var tweet: Tweet?
	
	private enum TweetMention: CustomStringConvertible {
		case Media([MediaItem])
		case Hashtags([BridgeMentionAndUser])
		case Urls([BridgeMentionAndUser])
		case UserMentions([BridgeMentionAndUser])
		
		var count: Int {
			switch self {
			case .Media(let items): return items.count
			case .Hashtags(let items): return items.count
			case .Urls(let items): return items.count
			case .UserMentions(let items): return items.count
			}
		}
		
		var mentions: [BridgeMentionAndUser] {
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
			case .UserMentions: return "User + UserMentions"
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
			var mentionsAndUser: [BridgeMentionAndUser] = tweet.userMentions
			mentionsAndUser = [tweet.user] + mentionsAndUser
			tweetMentions.append(TweetMention.UserMentions(mentionsAndUser))
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
			cell.textLabel?.text = mention.keywordOrScreenName
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
		case .Media:
			let cell = tableView.cellForRowAtIndexPath(indexPath) as! TweetMediaTableViewCell
			performSegueWithIdentifier(Constants.SegueToImageView, sender: cell)
		case .UserMentions:
			let mentions = tweetMention.mentions
			var keyword = mentions[indexPath.row].keywordOrScreenName
			keyword = keyword + " OR from:" + keyword
			recentSearchKeys.addSearchKey(keyword)
			performSegueWithIdentifier(Constants.SegueToMainTweetTableView, sender: self)
		case .Hashtags:
			let mentions = tweetMention.mentions
			let keyword = mentions[indexPath.row].keywordOrScreenName
			recentSearchKeys.addSearchKey(keyword)
			performSegueWithIdentifier(Constants.SegueToMainTweetTableView, sender: self)
		case .Urls(let mentions):
			let urlString = mentions[indexPath.row].keywordOrScreenName
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
	
	@IBAction private func popToRootViewController(sender: UIBarButtonItem) {
		navigationController?.popToRootViewControllerAnimated(true)
	}
	
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		guard let identifier = segue.identifier else { return }
		switch identifier {
		case Constants.SegueToImageView:
			if var vc = segue.destinationViewController.contentViewController as? NeedsMediaItem
			{	if let cell = sender as? TweetMediaTableViewCell {
					vc.image = cell.tweetImageView.image
				}
			}
		case Constants.SegueToMainTweetTableView:
			if let vc = segue.destinationViewController.contentViewController as? TweetTableViewController
			{	vc.searchTextFromSegue = recentSearchKeys.last
//				recentSearchKeys.removeAtIndex(0)
			}

		default: break
		}
    }


}
