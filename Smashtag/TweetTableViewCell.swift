//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Raymond Pau on 2/5/17.
//  Copyright © 2017 Raymond Pau. All rights reserved.
//

import UIKit
import Twitter

@IBDesignable
class TweetTableViewCell: UITableViewCell
{
    // outlets to the UI components in our Custom UITableViewCell
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    // public API of this UITableViewCell subclass
    // each row in the table has its own instance of this class
    // and each instance will have its own tweet to show
    // as set by this var
    var tweet: Twitter.Tweet? { didSet { updateUI() } }
    
    @IBInspectable var userMentionTextColor: UIColor = UIColor.orange { didSet { setNeedsDisplay() } }
    @IBInspectable var hashTagTextColor: UIColor = UIColor.purple { didSet { setNeedsDisplay() } }
    @IBInspectable var urlTextColor: UIColor = UIColor.blue { didSet { setNeedsDisplay() } }
    
    // whenever our public API tweet is set
    // we just update our outlets using this method
    private func updateUI() {
        tweetTextLabel?.text = tweet?.text
        let tweetText = NSMutableAttributedString(string: tweet?.text ?? "")
        if let userMentions = tweet?.userMentions {
            for mention in userMentions {
                tweetText.addAttributes([NSForegroundColorAttributeName: userMentionTextColor], range: mention.nsrange)
            }
        }
            
        if let hashtags = tweet?.hashtags {
            for mention in hashtags {
                tweetText.addAttributes([NSForegroundColorAttributeName: hashTagTextColor], range: mention.nsrange)
            }
        }
            
        if let urls = tweet?.urls {
            for mention in urls {
                tweetText.addAttributes([NSForegroundColorAttributeName: urlTextColor], range: mention.nsrange)
                tweetText.addAttributes([NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue], range: mention.nsrange)
            }
        }
        tweetTextLabel?.attributedText = tweetText
        tweetUserLabel?.text = tweet?.user.description
        
        if let profileImageURL = tweet?.user.profileImageURL {
            // FIXME: blocks main thread; FIXED
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if let imageData = try? Data(contentsOf: profileImageURL) {
                    DispatchQueue.main.async {
                        self?.tweetProfileImageView?.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            tweetProfileImageView?.image = nil
        }
        
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
    }
}
