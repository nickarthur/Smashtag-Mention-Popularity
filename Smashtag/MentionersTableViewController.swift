//
//  MentionersTableViewController.swift
//  Smashtag
//
//  Created by Michel Deiman on 19/06/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit
import CoreData


class MentionersTableViewController: CoreDataTableViewController
{
	// MARK: Model
	
	var mention: String? = "#matisse" { didSet { updateUI() } }
	var managedObjectContext: NSManagedObjectContext? {
		let delegate = UIApplication.sharedApplication().delegate
		return (delegate as? AppDelegate)?.managedObjectContext
	}

	override func viewDidLoad() {
		
		let stopBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop,
		                                        target: self,
		                                        action: #selector(self.popToRootViewController(_:)))
		if let rightBarButtonItem = navigationItem.rightBarButtonItem {
			navigationItem.rightBarButtonItems = [stopBarButtonItem, rightBarButtonItem]
		} else {
			navigationItem.rightBarButtonItem = stopBarButtonItem
		}
		
		updateUI()
	}
	
	private struct Constants {
		static let CellIdentifier = "PopularMentionsCell"
		static let SegueToMainTweetTableView = "ToMainTweetTableView"
	}
	
	private func updateUI() {
		if let context = managedObjectContext where mention?.isEmpty != true {
			let request = NSFetchRequest(entityName: "SearchTerm")
			request.predicate = NSPredicate(format: "keyword LIKE[cd] %@ AND count > %@", mention!, "1")

			let sortDescriptorA = NSSortDescriptor(key: "mention.type", ascending: true,  selector: #selector(NSString.localizedStandardCompare(_:)))
			let sortDescriptorB = NSSortDescriptor(key: "count", ascending: false)
			let sortDescriptorC = NSSortDescriptor(key: "mention.keyword", ascending: true,  selector: #selector(NSString.localizedStandardCompare(_:)))
			request.sortDescriptors = [sortDescriptorA, sortDescriptorB, sortDescriptorC]
			fetchedResultsController = NSFetchedResultsController(
				fetchRequest: request,
				managedObjectContext: context,
				sectionNameKeyPath: "mention.type",
				cacheName: nil)
			
		} else {
			fetchedResultsController = nil
		}
	}
	
	
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{	let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier, forIndexPath: indexPath)
		var keyword: String?
		var count: String?
		if let searchTermM = fetchedResultsController?.objectAtIndexPath(indexPath) as? SearchTerm {
			searchTermM.managedObjectContext?.performBlockAndWait {  // asynchronous
				keyword =  searchTermM.mention.keyword
				count = searchTermM.count.stringValue
			}
			cell.textLabel?.text = keyword
			cell.detailTextLabel?.text = "tweets.count: " + (count ?? "-")
		}
		
		return cell
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		guard let identifier = segue.identifier where identifier == Constants.SegueToMainTweetTableView,
			let cell = sender as? UITableViewCell
		else {
			return
		}
		let key = cell.textLabel?.text
		recentSearchKeys.addSearchKey(key!)
	}
		
	func popToRootViewController(sender: UIBarButtonItem) {
		navigationController?.popToRootViewControllerAnimated(true)
	}
	
}