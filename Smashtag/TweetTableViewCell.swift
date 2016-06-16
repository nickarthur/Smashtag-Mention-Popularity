//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Michel Deiman on 31/05/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit



class TweetTableViewCell: UITableViewCell {
	
	@IBOutlet weak var tweetScreenNameLabel: UILabel!
	@IBOutlet weak var tweetTextLabel: UILabel!
	@IBOutlet weak var tweetProfileImageview: UIImageView!
	@IBOutlet weak var tweetCreatedLabel: UILabel!

	var tweet: Tweet? {
		didSet {
			updateUI()
		}
	}
	
	private func updateUI() {
		tweetScreenNameLabel?.text = nil
		tweetTextLabel?.attributedText = nil
		tweetProfileImageview?.image = nil
		tweetCreatedLabel?.text = nil
		if let tweet = self.tweet {
			tweetTextLabel?.text = tweet.text
			if tweetTextLabel?.text != nil  {
				tweetTextLabel.attributedText = attributedTextFor(tweet, mentionTypes: [.HashTag, .URL, .User])
				tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
				
				if let profileImageURL = tweet.user.profileImageURL {
					let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
					dispatch_async(dispatch_get_global_queue(qos, 0)) { [ weak weakSelf = self ] in
						if let imageData = NSData(contentsOfURL: profileImageURL) {
							dispatch_async(dispatch_get_main_queue()) {
								weakSelf?.tweetProfileImageview?.image = UIImage(data: imageData)
							}
						}
					}
				}
				
				let formatter = NSDateFormatter()
				if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
					formatter.dateStyle = NSDateFormatterStyle.ShortStyle
				} else {
					formatter.timeStyle = NSDateFormatterStyle.ShortStyle
				}
				tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
			}
		}
		
	}
	
	private func attributedTextFor(tweet: Tweet, mentionTypes: [MentionType]) -> NSAttributedString {
		var tweetText = tweet.text
		for _ in tweet.media {
			tweetText += " 📷"
		}
		let attributedText = NSMutableAttributedString(string: tweetText)
		
		
		for mentionType in mentionTypes {
			var color: UIColor
			var mentions: [Mention]
			switch mentionType {
			case .HashTag:
				color = Palette.HashtagColor
				mentions = tweet.hashtags
			case .URL:
				color = Palette.UrlColor
				mentions = tweet.urls
			case .User:
				color = Palette.UserColor
				mentions = tweet.userMentions
			}
			for mention in mentions {
				attributedText.addAttribute(NSForegroundColorAttributeName, value: color, range: mention.nsrange)
			}
		}
		return attributedText
	}
}

private struct Palette {
	static let HashtagColor = UIColor.purpleColor()
	static let UrlColor = UIColor.blueColor()
	static let UserColor = UIColor.orangeColor()
}

private enum MentionType {
	case HashTag, URL, User
}





