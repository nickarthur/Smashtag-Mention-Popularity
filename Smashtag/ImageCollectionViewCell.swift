//
//  ImageCollectionViewCell.swift
//  Smashtag
//
//  Created by Michel Deiman on 16/06/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit
import Twitter

class ImageCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet private weak var imageView: UIImageView!
	
	var tweet: Tweet?
	var mediaItem: MediaItem? {
		didSet {
			fetchImage()
			spinner?.stopAnimating()
		}
	}
	var cache: NSCache?
	
	@IBOutlet private weak var spinner: UIActivityIndicatorView!
	
	private func fetchImage() {
		guard let url = mediaItem?.url else { return }
		spinner?.startAnimating()
		if let imageData = cache?[url] as? NSData {
			imageView.image = UIImage(data: imageData)
			return
		}
		dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0))
		{	let imageData = NSData(contentsOfURL: url)
			dispatch_async(dispatch_get_main_queue())
			{ 	[ weak weakSelf = self ] in
				guard url == weakSelf?.mediaItem?.url else { return }
				weakSelf?.imageView.image = nil
				if let imageData = imageData  {
					weakSelf?.imageView?.image = UIImage(data: imageData)
					weakSelf?.cache?[url] = imageData
				}
				self.spinner?.stopAnimating()
				
			}
		}
	}
}


