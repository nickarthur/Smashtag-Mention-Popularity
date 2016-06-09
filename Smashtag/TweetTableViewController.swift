//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Michel Deiman on 31/05/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit
import Twitter


class TweetTableViewController: UITableViewController, UITextFieldDelegate {
	
	private var tweets = [Array<Tweet>]() {
		didSet {
			tableView.reloadData()
		}
	}
	
	private var searchText: String? {
		didSet {
			guard let searchText = searchText where searchText != ""
			else {
				searchTextField.text = recentSearchKeys.last
				return
			}
			recentSearchKeys.addSearchKey(searchText)
			tweets.removeAll()
			searchForTweets()
			title = searchText
			searchTextField.text = searchText
		}
	}
	
	private struct Constants {
		static let SegueIdentifierToMentions = "ToMentions"
		static let TweetCellIdentifier = "Tweet"
	}
	
	private var twitterRequest: Request? {
		if let query = searchText where !query.isEmpty {
			return Request(search: query + " -filter:retweets", count: 100)
		}
		return nil
	}
	
	private var lastTwitterRequest: Request?

	private func searchForTweets() {
		if let request = twitterRequest {
			lastTwitterRequest = request
			request.fetchTweets { [weak weakSelf = self] newTweets in
				dispatch_async(dispatch_get_main_queue()) {
					if request == weakSelf?.lastTwitterRequest {
						if !newTweets.isEmpty {
							weakSelf?.tweets.insert(newTweets, atIndex: 0)
						}
					}
				}
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.estimatedRowHeight = tableView.rowHeight  // storyboard..
		tableView.rowHeight = UITableViewAutomaticDimension
    }
	
	override func viewWillAppear(animated: Bool) {
		let mostRecentSearchKey = recentSearchKeys.last
		if searchText != mostRecentSearchKey {
			searchText = mostRecentSearchKey
		}
	}


    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TweetCellIdentifier, forIndexPath: indexPath)
		let tweet = tweets[indexPath.section][indexPath.row]
		
		if let tweetCell = cell as? TweetTableViewCell {
			tweetCell.tweet = tweet
		}
        return cell
    }
 
	@IBOutlet private weak var searchTextField: UITextField! {
		didSet {
			searchTextField.delegate = self
			searchTextField.text = searchText
		}
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		searchText = textField.text
		return true
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{	tweetForSegue = tweets[indexPath.section][indexPath.row]
		performSegueWithIdentifier(Constants.SegueIdentifierToMentions, sender: self)
	}

	private var tweetForSegue: Tweet?
	
	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		switch identifier {
		case Constants.SegueIdentifierToMentions: return tweetForSegue != nil
		default: return true
		}
	}
	
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{	guard let identifier = segue.identifier where identifier == Constants.SegueIdentifierToMentions
		else { return }
		if var vc = segue.destinationViewController.contentViewController as? NeedsTweet {
			vc.tweet = tweetForSegue
			tweetForSegue = nil
		}
		
	}

}

extension UIViewController
{
	var contentViewController: UIViewController? {
		if let navcon = self as? UINavigationController {
			return navcon.visibleViewController
		} else {
			return self
		}
	}
}
