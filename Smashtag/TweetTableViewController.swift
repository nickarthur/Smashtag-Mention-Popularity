//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Michel Deiman on 31/05/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class TweetTableViewController: UITableViewController, UISearchBarDelegate
{
	// MARK: Model
	
	var managedObjectContext: NSManagedObjectContext? {
		let delegate = UIApplication.sharedApplication().delegate
		return (delegate as? AppDelegate)?.managedObjectContext
	}
	
	private var tweets = [[Tweet]]()
	
	var searchTextFromSegue: String?
	
	private var searchText: String? {
		didSet {
			guard let searchText = searchText where searchText != ""
			else {
				searchTextField.text = recentSearchKeys.last
				return
			}
			tweets.removeAll()
			lastTwitterRequest = nil
			refreshTweetsTable()
			title = searchText
			searchTextField.text = searchText
		}
	}
	
	private struct Constants {
		static let SegueIdentifierToMentions = "ToMentions"
		static let SegueIdentifierToCollectionView = "toCollectionViewOfImages"
		static let TweetCellIdentifier = "Tweet"
	}
	

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.estimatedRowHeight = tableView.rowHeight  // storyboard..
		tableView.rowHeight = UITableViewAutomaticDimension
		
		if navigationController?.viewControllers.count > 1 {
			let stopBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop,
							target: self,
							action: #selector(TweetTableViewController.popToRootViewController(_:)))
			
			if let rightBarButtonItem = navigationItem.rightBarButtonItem {
				navigationItem.rightBarButtonItems = [stopBarButtonItem, rightBarButtonItem]
			} else {
				navigationItem.rightBarButtonItem = stopBarButtonItem
			}
			
		}
		
		if let searchText = searchTextFromSegue {
			self.searchText = searchText
			searchTextFromSegue = nil
			
		} else {
			let mostRecentSearchKey = recentSearchKeys.last
			searchText = mostRecentSearchKey
		}
    }
	
	override func viewWillDisappear(animated: Bool) {
		searchTextField.resignFirstResponder()
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
 
	// MARK: tableView delegate method
	// segue not directly from tableViewCell to other controller...
	// use this as a cancel option for keyboard: resignFirstResponder()
	override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if searchTextField.isFirstResponder() {
			searchTextField.resignFirstResponder()
			return false
		} else {
			return true
		}
	}
	
	// Perform Segue ..
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{	tweetForSegue = tweets[indexPath.section][indexPath.row]
		performSegueWithIdentifier(Constants.SegueIdentifierToMentions, sender: self)
	}
	
	@IBOutlet private weak var searchTextField: UISearchBar! {
		didSet {
			searchTextField.delegate = self
			searchTextField.text = searchText
			let cancelButton = searchTextField.valueForKey("cancelButton") as! UIButton
			cancelButton.setTitle("Search", forState: .Normal)
		}
	}
	
	// MARK: Delegate method from UISearchBarDelegate
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		searchText = searchBar.text
		recentSearchKeys.addSearchKey(searchText!)
	}
	
	// MARK: UISearchBarDelegate method !!!!!!!
	// Not "Cancel, but 'Enter'-function !!!!!
	// twitter keyboard has no enter key?  TEMPORARY SOLUTION
	func searchBarCancelButtonClicked(searchBar: UISearchBar) {
		searchBarSearchButtonClicked(searchBar)
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		searchText = textField.text
		recentSearchKeys.addSearchKey(searchText!)
		return true
	}
	
	
	private var lastTwitterRequest: Request?
	private var twitterRequest: Request? {
		if lastTwitterRequest == nil {
			if let query = searchText where !query.isEmpty {
				return Request(search: query + " -filter:retweets", count: 100)
			}
			return nil
		} else {
			return lastTwitterRequest!.requestForNewer
		}
	}
	
	// MARK: - Refreshing the tweetsTable(View)
	@IBAction private func refreshTweetsTable(sender: UIRefreshControl?) {
		guard searchText != nil else {
			sender?.endRefreshing()
			return
		}
		guard let request = twitterRequest else { return }
		lastTwitterRequest = request
		request.fetchTweets { [weak weakSelf = self] newTweets in
			dispatch_async(dispatch_get_main_queue()) {
				if !newTweets.isEmpty {
					weakSelf?.tweets.insert(newTweets, atIndex: 0)
					weakSelf?.tableView.reloadData()
					weakSelf?.tableView.reloadSections(NSIndexSet(indexesInRange:
						NSMakeRange(0, self.tableView.numberOfSections)),
						withRowAnimation: .None)
					weakSelf?.updateDatabase(newTweets)
					sender?.endRefreshing()
					self.title = self.searchText
				}
				sender?.endRefreshing()
			}
		}
	}
	
	private func updateDatabase(newTweets: [Tweet])
	{
		managedObjectContext?.performBlock {
			for tweet in newTweets {
				_ = TweetM.tweetWith(tweet, forSearchTerm: self.searchText!, inManagedObjectContext: self.managedObjectContext!)
				guard let _ = try? self.managedObjectContext?.save()
				else {
					print("not saved...")
					break
				}
				// error not handled...
			}
		}
		printDatabaseStatistics()
		print("done printing printDatabaseStatistics")
	}
	
	private func printDatabaseStatistics() {
		managedObjectContext?.performBlock
		{	if let results = try? self.managedObjectContext!.executeFetchRequest(NSFetchRequest(entityName: "UserM"))
			{	print("\(results.count) TwitterUsers")
			}
			let tweetMCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "TweetM"), error: nil)
			print(tweetMCount, " Tweets")
			let mentionsCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "MentionM"), error: nil)
			print(mentionsCount, " Mentions")
			let searchTermCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "SearchTerm"), error: nil)
			print(searchTermCount, " searchTermCount")
		}
	}
	
	private func refreshTweetsTable() {
		refreshControl?.beginRefreshing()
		refreshTweetsTable(refreshControl)
	}
	
	// MARK: Segue methods and property
	private var tweetForSegue: Tweet?
	
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{	guard let identifier = segue.identifier else { return }
		let destinationVC = segue.destinationViewController.contentViewController
		switch identifier {
		case Constants.SegueIdentifierToMentions:
			if var vc = destinationVC as? NeedsTweet {
				vc.tweet = tweetForSegue
				tweetForSegue = nil
			}
		case Constants.SegueIdentifierToCollectionView:
			if let vc = destinationVC as? NeedsTweets {
				vc.tweets = tweets
			}
		default: break
		}
	}

	func popToRootViewController(sender: UIBarButtonItem) {
		navigationController?.popToRootViewControllerAnimated(true)
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
