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
		updateUI()
	}
	struct Constants {
		static let CellIdentifier = "PopularMentionsCell"
	}
	
	private func updateUI() {
		if let context = managedObjectContext where mention?.isEmpty != true {
			let request = NSFetchRequest(entityName: "MentionM")
			request.predicate = NSPredicate(format: "any keyword contains[c] %@", mention!)
			request.sortDescriptors = [NSSortDescriptor(key: "keyword", ascending: true)]
			fetchedResultsController = NSFetchedResultsController(
				fetchRequest: request,
				managedObjectContext: context,
				sectionNameKeyPath: nil,
				cacheName: nil)
			
		} else {
			fetchedResultsController = nil
		}
		
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{	let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier, forIndexPath: indexPath)
		var keyword: String?
		var frequency: Int?
		if let mentionM = fetchedResultsController?.objectAtIndexPath(indexPath) as? MentionM {
			mentionM.managedObjectContext?.performBlockAndWait {  // asynchronous
				keyword = mentionM.keyword
				frequency = mentionM.tweets.count
			}
			cell.textLabel?.text = keyword
			cell.detailTextLabel?.text = String(frequency ?? 0)
		}
		
		return cell
	}
	
	
	
	
	
	
	
}