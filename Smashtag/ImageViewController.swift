//
//  ImageViewController.swift
//  Smashtag
//
//  Created by Michel Deiman on 09/06/16.
//  Copyright © 2016 Michel Deiman. All rights reserved.
//

import UIKit

protocol NeedsMediaItem {
	weak var image: UIImage? { get set }
}

class ImageViewController: UIViewController, UIScrollViewDelegate ,NeedsMediaItem {
	
	weak var image: UIImage? {
		didSet {
			imageView = UIImageView(image: image)
			imageView.contentMode = .ScaleAspectFit
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		scrollView.delegate = self
		scrollView.contentSize = imageView.bounds.size
		scrollView.addSubview(imageView)
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		zoomScaleToAspectFit()
	}

	// MARK: - UIScrollView Delegate methods ...
	func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	
	private var autoZoom = true
	
	func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
		autoZoom = false
	}
	
	@IBOutlet private weak var scrollView: UIScrollView!
	private var imageView: UIImageView!
	
	private func zoomScaleToAspectFit() {
		let zoomScaleForHeight = scrollView.bounds.height / imageView.bounds.height
		let zoomScaleForWidth = scrollView.bounds.width / imageView.bounds.width
		
		scrollView.minimumZoomScale = min(zoomScaleForHeight, zoomScaleForWidth)
		scrollView.maximumZoomScale = 5
		if autoZoom {
			scrollView.zoomScale = max(zoomScaleForHeight, zoomScaleForWidth)
		}
		let contentOffSetX = (scrollView.contentSize.width - scrollView.bounds.width) / 2
		let contentOffSetY = (scrollView.contentSize.height - scrollView.bounds.height) / 2
		scrollView.contentOffset = CGPoint(x: contentOffSetX, y: contentOffSetY)
	}
	
	@IBAction private func popToRootViewController(sender: UIBarButtonItem) {
		navigationController?.popToRootViewControllerAnimated(true)
	}
	
	
}
