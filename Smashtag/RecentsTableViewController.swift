//
//  RecentsTableViewController.swift
//  Smashtag
//
//  Created by Michel Deiman on 08/06/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit

private struct Constants {
	static let MaxSearchKeys = 100
	static let KeyForRecentSearches = "RecentSearchKeys"
	static let cellReuseIdentifier = "Recents"
	static let SegueToMainTweetTableView = "ToMainTweetTableView"
}

class RecentSearchKeys {
	subscript(index: Int) -> String {
		get { return searchKeys[index] }
	}
	
	var last: String {
		return !isEmpty ? self[0] : "#stanford"
	}
	
	var count: Int {
		return searchKeys.count
	}
	
	var isEmpty: Bool {
		return self.count == 0
	}
	
	func addSearchKey(key: String) {
		for index in 0..<searchKeys.count
		{	if key.lowercaseString == searchKeys[index].lowercaseString {
			searchKeys.removeAtIndex(index)
			break
			}
		}
		searchKeys.insert(key, atIndex: 0)
		if searchKeys.count >= Constants.MaxSearchKeys {
			searchKeys.removeLast()
		}
	}
	
	func moveToTop(key: String) {
		addSearchKey(key)
	}
	
	func removeAtIndex(index: Int) {
		if count > index {
			searchKeys.removeAtIndex(index)
		}
	}
	
	func remove(key: String) {
		for index in 0..<searchKeys.count
		{	if key.lowercaseString == searchKeys[index].lowercaseString {
			searchKeys.removeAtIndex(index)
			return
			}
		}
	}
	
	private let defaults = NSUserDefaults.standardUserDefaults()
	private let keyForData: String
	
	private var searchKeys: [String] {
		get {	return defaults.objectForKey(keyForData) as? [String] ?? []	}
		set {	defaults.setObject(newValue, forKey: keyForData)	}
	}

	init(keyForData: String) {
		self.keyForData = keyForData
	}
}

// global singleton??
var recentSearchKeys = RecentSearchKeys(keyForData: Constants.KeyForRecentSearches)

class RecentsTableViewController: UITableViewController {
	
	override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
	
	override func viewWillAppear(animated: Bool) {
		tableView.reloadData()
	}

    // MARK: - Table view data source
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearchKeys.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.cellReuseIdentifier, forIndexPath: indexPath)
		cell.textLabel?.text = recentSearchKeys[indexPath.row]
        return cell
    }


	
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

	
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
			recentSearchKeys.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		let key = recentSearchKeys[indexPath.row]
		recentSearchKeys.moveToTop(key)
		performSegueWithIdentifier(Constants.SegueToMainTweetTableView, sender: self)
	}

}
