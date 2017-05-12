//
//  ImageCollectionViewController.swift
//  Smashtag
//
//  Created by Raymond Pau on 10/5/17.
//  Copyright © 2017 Raymond Pau. All rights reserved.
//

import UIKit
import Twitter

private let reuseIdentifier = "Image Cell"
private let ShowTweetSegueIdentifier = "Show Tweet"

class TweetImageCollectionViewController: UICollectionViewController
{
    // Mark: Model
    
    var tweets = Array<Twitter.Tweet>() {
        didSet {
            imageCollection.removeAll()
            for tweet in tweets {
                imageCollection.append(contentsOf: tweet.media.map({ $0.url }))
            }
        }
    }
    
    var imageCaches = NSCache<NSURL, UIImage>()
    
    private var imageCollection = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = collectionView!.bounds.width / 3
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowTweetSegueIdentifier {
            if let tweetTVC = (segue.destination as? TweetTableViewController) {
                let cell = sender as! ImageCollectionViewCell
                tweetTVC.insertTweets([tweets[cell.tag]])   // Need to find the exact tweet this cell refer to
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageCollection.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        // Configure the cell
        // Will use cell.tag when user touch image to link back to the tweet image belongs to
        cell.tag = indexPath.row
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let imageCell = cell as! ImageCollectionViewCell
        
        let url = imageCollection[indexPath.row]
        if let image = (imageCaches.object(forKey: url as NSURL)) {
            imageCell.imageView.image = image
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async { [weak self] in
                        if let image = UIImage(data: imageData) {
                            self?.imageCaches.setObject(image, forKey: url as NSURL)
                            imageCell.imageView.image = image
                        }
                    }
                }
            }
        }
    }
}
