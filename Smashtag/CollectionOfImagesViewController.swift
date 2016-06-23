//
//  CollectionOfImagesViewController.swift
//  Smashtag
//
//  Created by Michel Deiman on 14/06/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit
import Twitter

extension NSCache {
	subscript(key: AnyObject) -> AnyObject? {
		get {
			return objectForKey(key)
		}
		set {
			if let value: AnyObject = newValue {
				setObject(value, forKey: key)
			} else {
				removeObjectForKey(key)
			}
		}
	}
}

private struct Constants {
	static let ReuseIdentifier = "imageCollectionViewCell"
	static let SegueToMainTweetTableView = "ToMainTweetTableView"
	
	static let MaxColumnCount: CGFloat = 4
	static let MaxRowCount: CGFloat = 6
	
	static let minimumColumnSpacing:CGFloat = 2
	static let minimumInteritemSpacing:CGFloat = 0
	static let minimumLineSpacing: CGFloat = 2
	static let sectionInset = UIEdgeInsetsZero
}

protocol NeedsTweets: class {
	var tweets: [[Tweet]]? { get set }
}

class CollectionOfImagesViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout,NeedsTweets {

	var tweets: [[Tweet]]? {
		didSet {
			for allTweets in tweets! {
				for tweet in allTweets {
					for media in tweet.media {
						tweetsWithMedia.append(TweetWithMedia(tweet: tweet, mediaItem: media))
					}
				}
			}
		}
	}
	
	private struct TweetWithMedia {
		let tweet: Tweet
		let mediaItem: MediaItem
	}

	private var tweetsWithMedia: [TweetWithMedia] = []
	private var cache = NSCache()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		title = "Images"
		collectionViewFlowLayout = UICollectionViewFlowLayout()
		
		self.installsStandardGestureForInteractiveMovement = true
		collectionView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(CollectionOfImagesViewController.scaleCollectionViewGrid(_:))))
		
		let stopBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop,
		                                        target: self,
		                                        action: #selector(TweetTableViewController.popToRootViewController(_:)))
		if let rightBarButtonItem = navigationItem.rightBarButtonItem {
			navigationItem.rightBarButtonItems = [stopBarButtonItem, rightBarButtonItem]
		} else {
			navigationItem.rightBarButtonItem = stopBarButtonItem
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		collectionView?.collectionViewLayout.invalidateLayout()
	}
	
	override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
		let temp = rowCount
		rowCount = columnCount
		columnCount = temp
		collectionView?.collectionViewLayout.invalidateLayout()
	}
	
	func scaleCollectionViewGrid(gesture: UIPinchGestureRecognizer) {
		var startLocationFinger1 = CGPoint()
		var startLocationFinger2 = CGPoint()

		switch gesture.state {
		case .Began:  	// how to handle more then 2 fingers?
			startLocationFinger1 = gesture.locationOfTouch(0, inView: collectionView)
			startLocationFinger2 = gesture.locationOfTouch(1, inView: collectionView)
			
		case .Changed:
			guard gesture.scale > 1.25 || gesture.scale < 0.85 else { break }
			let targetFinger1 = gesture.locationOfTouch(0, inView: collectionView)
			let targetFinger2 = gesture.locationOfTouch(1, inView: collectionView)
			
			let deltaX = abs((startLocationFinger1.x - startLocationFinger2.x) -
							 (targetFinger1.x - targetFinger2.x))
			let deltaY = abs((startLocationFinger1.y - startLocationFinger2.y) -
							 (targetFinger1.y - targetFinger2.y))
			let deltaXY = deltaX / deltaY
			
			switch deltaXY {
			case 0..<0.4: 				// y movement > 2.5 * x movement
				rowCount = gesture.scale > 1 ? rowCount - 1 : rowCount + 1
			case 0.4..<3.0:
				columnCount = gesture.scale > 1 ? columnCount - 1 : columnCount + 1
				rowCount = gesture.scale > 1 ? rowCount - 1 : rowCount + 1
			default:					// x movement > 3 * y movement
				columnCount = gesture.scale > 1 ? columnCount - 1 : columnCount + 1
			}
			
			startLocationFinger1 = targetFinger1
			startLocationFinger2 = targetFinger2

			gesture.scale = 1.0
			collectionView?.collectionViewLayout.invalidateLayout()
		default: break
		}
	}
	
	deinit {
		cache.removeAllObjects()
	}

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweetsWithMedia.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.ReuseIdentifier, forIndexPath: indexPath) as! ImageCollectionViewCell
    	cell.mediaItem = tweetsWithMedia[indexPath.row].mediaItem
		cell.tweet = tweetsWithMedia[indexPath.row].tweet
		cell.cache = cache
        return cell
    }
	
	override func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	override func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
	{
		let tempTweetWithMedia = tweetsWithMedia[destinationIndexPath.row]
		tweetsWithMedia[destinationIndexPath.row] = tweetsWithMedia[sourceIndexPath.row]
		tweetsWithMedia[sourceIndexPath.row] = tempTweetWithMedia
		collectionView.collectionViewLayout.invalidateLayout()
	}

	// MARK: UICollectionViewDelegateFlowLayout - an altertenative would be delegate methods for these properties...
	private var collectionViewFlowLayout: UICollectionViewFlowLayout? {
		didSet {
			collectionViewFlowLayout!.minimumLineSpacing = Constants.minimumLineSpacing
			collectionViewFlowLayout!.minimumInteritemSpacing = Constants.minimumInteritemSpacing
			collectionViewFlowLayout!.sectionInset = Constants.sectionInset
			
			collectionView?.collectionViewLayout = collectionViewFlowLayout!
		}
	}
	
	private var columnCount: CGFloat = 2 {
		didSet {
			columnCount = min(max(columnCount, 1), Constants.MaxColumnCount)
			collectionView?.pagingEnabled = columnCount == 1 && rowCount == 1
		}
	}

	private var rowCount: CGFloat = 3 {
		didSet {
			rowCount = min(max(rowCount, 1), Constants.MaxRowCount)
			collectionView?.pagingEnabled = columnCount == 1 && rowCount == 1
		}
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

		let width = (collectionView.bounds.width - (columnCount - 1) * 2) / columnCount
		let height = (collectionView.bounds.height - (rowCount - 1) * 2) / rowCount
		return CGSize(width: width, height: height)
	}
	
	func collectionView(collectionView: UICollectionView,
	                    layout collectionViewLayout: UICollectionViewLayout,
	                           insetForSectionAtIndex section: Int) -> UIEdgeInsets {
		return UIEdgeInsetsZero
	}
	
	
    // MARK: UICollectionViewDelegate
	// None implemented ... see UICollectionViewDelegateFlowLayout
	
	// MARK: - Navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{	if let identifier = segue.identifier where identifier == Constants.SegueToMainTweetTableView
		{	let vc = segue.destinationViewController.contentViewController as! TweetTableViewController
			if let cell = sender as? ImageCollectionViewCell {
				vc.searchTextFromSegue = cell.tweet!.id
			}
		}
	}
	
	@IBAction private func popToRootViewController(sender: UIBarButtonItem) {
		navigationController?.popToRootViewControllerAnimated(true)
	}

}
