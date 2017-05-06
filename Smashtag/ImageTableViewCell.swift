//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Raymond Pau on 6/5/17.
//  Copyright © 2017 Raymond Pau. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell
{
    @IBOutlet weak var tweetImage: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var imageURL: URL? {
        didSet {
            spinner.stopAnimating()
            if let url = imageURL {
                spinner.startAnimating()
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    if let imageData = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            if url == self?.imageURL {
                                self?.tweetImage.image = UIImage(data: imageData)
                            }
                            self?.spinner.stopAnimating()
                        }
                    }
                }
            }
        }
    }
}
