//
//  TweetMediaTableViewCell.swift
//  Smashtag
//
//  Created by Michel Deiman on 18/06/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//


import UIKit
import Twitter

class TweetMediaTableViewCell: UITableViewCell {
	
	@IBOutlet weak var tweetImageView: UIImageView!
	@IBOutlet weak var spinner: UIActivityIndicatorView!
	
	weak var mediaItem: MediaItem? {
		didSet {
			updateUI()
		}
	}
	
	private func updateUI()
	{	guard let url = mediaItem?.url else { return }
		spinner?.startAnimating()
		dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
		{	let imageData = NSData(contentsOfURL: url)
			dispatch_async(dispatch_get_main_queue())
			{	if url == self.mediaItem?.url {
				if imageData != nil {
					self.tweetImageView?.image = UIImage(data: imageData!)
				} else {
					self.tweetImageView?.image = nil
				}
				self.spinner?.stopAnimating()
				}
			}
		}
	}
	
	override func setSelected(selected: Bool, animated: Bool)
	{	super.setSelected(selected, animated: animated)
	}
}