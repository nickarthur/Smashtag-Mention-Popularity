//
//  CollectionOfImagesViewController.swift
//  Smashtag
//
//  Created by Michel Deiman on 14/06/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit

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
	
	struct TweetWithMedia {
		let tweet: Tweet
		let mediaItem: MediaItem
	}

	var tweetsWithMedia: [TweetWithMedia] = []
	var cache = NSCache()
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		title = "Images"
		collectionViewFlowLayout = UICollectionViewFlowLayout()
		
		self.installsStandardGestureForInteractiveMovement = true
		collectionView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(CollectionOfImagesViewController.scale(_:))))
		
		let stopBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop,
		                                        target: self,
		                                        action: #selector(TweetTableViewController.popToRootViewController(_:)))
		if let rightBarButtonItem = navigationItem.rightBarButtonItem {
			navigationItem.rightBarButtonItems = [stopBarButtonItem, rightBarButtonItem]
		} else {
			navigationItem.rightBarButtonItem = stopBarButtonItem
		}
	}
	
	
	func scale(gesture: UIPinchGestureRecognizer) {
		struct WhereToGo {
			enum Directions {
				case Horizontal, Vertical, Diagonal
			}
			static var direction = Directions.Diagonal
		}
		
		switch gesture.state {
		case .Began:
			if gesture.numberOfTouches() == 2 {
				let location1 = gesture.locationOfTouch(0, inView: collectionView)
				let location2 = gesture.locationOfTouch(1, inView: collectionView)
				let relX = abs(location2.x - location1.x) / collectionView!.bounds.width
				let relY = abs(location2.y - location1.y) / collectionView!.bounds.height
				if relX < 0.1 {
					WhereToGo.direction = .Vertical
				} else if relY < 0.1 {
					WhereToGo.direction = .Horizontal
				} else {
					WhereToGo.direction = .Diagonal
				}
			}
		case .Changed:
			if gesture.scale > 1.5 || gesture.scale < 0.667 {
				switch WhereToGo.direction {
				case .Horizontal:
					columnCount = gesture.scale > 1.5 ? columnCount - 1 : columnCount + 1
				case .Vertical:
					rowCount = gesture.scale > 1.5 ? rowCount - 1 : rowCount + 1
				case .Diagonal:
					columnCount = gesture.scale > 1.5 ? columnCount - 1 : columnCount + 1
					rowCount = gesture.scale > 1.5 ? rowCount - 1 : rowCount + 1
					collectionView?.collectionViewLayout.invalidateLayout()
				}
				gesture.scale = 1.0
				collectionView?.collectionViewLayout.invalidateLayout()
			}
		case .Ended:
			WhereToGo.direction = .Diagonal
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
			if columnCount < 1 {
				columnCount = 1
			}
			else if columnCount > Constants.MaxColumnCount {
				columnCount = Constants.MaxColumnCount
			}
		}
	}

	private var rowCount: CGFloat = 3 {
		didSet {
			if rowCount < 1 {
				rowCount = 1
			}
			else if rowCount > Constants.MaxRowCount {
				rowCount = Constants.MaxRowCount
			}
		}
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

		let width = (collectionView.bounds.width - (columnCount - 1) * 2) / columnCount
		let height = (collectionView.bounds.height - (rowCount - 1) * 2) / rowCount
		let cgSize = CGSize(width: width, height: height)
		return cgSize
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
