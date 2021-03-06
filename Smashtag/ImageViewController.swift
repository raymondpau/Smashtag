//
//  ImageViewController.swift
//  Cassini
//
//  Created by Raymond Pau on 1/5/17.
//  Copyright © 2017 Raymond Pau. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController
{
    // MARK: Model
    
    var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil { // if we're on screen
                fetchImage()        // then fetch image
            }
        }
    }
    
    
    // MARK: Private Implementation
    
    // when we dropped this spinner into our storyboard
    // it initially put it as a subview of our scrollView!
    // we used the Document Outline to drag it out to be a sibling of scrollView
    // instead of a subview
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            // to zoom we have to handle viewForZooming(in scrollView:)
            scrollView.delegate = self
            // most important thing to set in UIScrollView is contentsize
            scrollView.contentSize = imageView.frame.size
            scrollView.addSubview(imageView)
        }
    }
    
    private func fetchImage() {
        if let url = imageURL {
            // we're going to start something on another queue soon
            // so let's start a spinner going in the UI to let the user know
            // we'll stop this any time an image actually gets set
            // (we'd never want the spinner and an image appearing at the same time!)
            spinner.startAnimating()
            // try? Data(contentsOf:) blocks the thread it is on
            // we are currently on the main thread
            // so we must dispatch that call off to a background queue
            // we'll use one of the shared, global, concurrent background queues
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                // now that we're back from blocking
                // are we still even interested in this url (i.e. does it == self.imageURL)?
                if let imageData = urlContents, url == self?.imageURL {
                    // now we want to set the image in the UI
                    // but we are not on the main thread right now
                    // so we are not allowed to do UI
                    // no problem: just dispatch the UI stuff back to the main queue
                    DispatchQueue.main.async {
                        self?.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
    
    // MARK: View Controller Lifecycle
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {   // we're about to appear on screen so, if needed,
            fetchImage()    // fetch image
        }
    }
    
    fileprivate var imageView = UIImageView()
    fileprivate var scrollViewDidScrollOrZoom = false
    
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            // careful here because scrollView might be nil
            // (for example, if we're setting our image as part of a prepare)
            // so use optional chaining to do nothing
            // if our scrollView outlet has not yet been set
            scrollView?.contentSize = imageView.frame.size
            
            // now that we've set an image
            // stop any spinner that exists from spinning
            spinner?.stopAnimating()
            
            autoScale()
            scrollViewDidScrollOrZoom = false
        }
    }
    
    private func autoScale() {
        if image != nil && scrollView != nil {
            scrollView.zoomScale = max(scrollView.bounds.size.height / image!.size.height,
                                scrollView.bounds.size.width / image!.size.width)
            scrollView.contentOffset = CGPoint(x: (imageView.frame.size.width - scrollView.frame.size.width) / 2,
                                               y: (imageView.frame.size.height - scrollView.frame.size.height) / 2)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !scrollViewDidScrollOrZoom {
            autoScale()
        }
    }
}

// MARK: UIScrollViewDelegate
// Extension which makes ImageViewController conform to UIScrollViewDelegate
// Handles viewForZooming(in scrollView:)
// by returning the UIImageView as the view to transform when zooming

extension ImageViewController : UIScrollViewDelegate
{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView;
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewDidScrollOrZoom = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScrollOrZoom = true
    }
}
