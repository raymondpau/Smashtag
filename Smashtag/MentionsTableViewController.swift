//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Raymond Pau on 6/5/17.
//  Copyright © 2017 Raymond Pau. All rights reserved.
//

import UIKit
import Twitter

@IBDesignable
class MentionsTableViewController: UITableViewController
{
    // MARK : Model
    private var mentions = [Mentions]()
    
    private struct Mentions: CustomStringConvertible {
        var title: String
        var data: [MentionItem]
        var description: String { return "\(title): \(data)" }
    }
    
    private enum MentionItem: CustomStringConvertible {
        case Keyword(String, UIColor)
        case Image(URL, Double)
        
        var description: String {
            switch self {
            // For hashtags, user screen names and urls
            case .Keyword(let keyword, _): return keyword
            case .Image(let url, _): return url.path
            }
        }
    }
    private struct Title {
        static let images = "Images"
        static let hasttags = "Hashtags"
        static let users = "Users"
        static let urls = "URLs"
    }
    
    private struct StoryBoard {
        static let KeyworkCellIdentifier = "Keyword Cell"
        static let ImageCellIdentifier = "Image Cell"
    }
    
    @IBInspectable var hashTagTextColor: UIColor = UIColor.purple
    @IBInspectable var userTextColor: UIColor = UIColor.orange
    @IBInspectable var urlTextColor: UIColor = UIColor.blue

    // MARK: Public API
    var tweet: Twitter.Tweet? {
        didSet {
            title = tweet?.user.screenName
            if let media = tweet?.media, !media.isEmpty {
                mentions.append(Mentions(title: Title.images, data: media.map { MentionItem.Image($0.url, $0.aspectRatio) }))
            }
            if let hashtags = tweet?.hashtags, !hashtags.isEmpty {
                mentions.append(Mentions(title: Title.hasttags, data: hashtags.map { MentionItem.Keyword($0.keyword, hashTagTextColor) }))
            }
            if let users = tweet?.userMentions, !users.isEmpty {
                mentions.append(Mentions(title: Title.users, data: users.map { MentionItem.Keyword($0.keyword, userTextColor) }))
            }
            if let urls = tweet?.urls, !urls.isEmpty {
                mentions.append(Mentions(title: Title.urls, data: urls.map { MentionItem.Keyword($0.keyword, urlTextColor)}))
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return mentions.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentions[section].data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mention = mentions[indexPath.section].data[indexPath.row]
        
        // Configure the cell...
        switch mention {
        case .Image(let url, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.ImageCellIdentifier, for: indexPath)
            if let imageTVC = cell as? ImageTableViewCell {
                imageTVC.imageURL = url
            }
            return cell

        case .Keyword(let keyword, let textColor):
            let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.KeyworkCellIdentifier, for: indexPath)
            cell.textLabel?.attributedText = NSAttributedString(string: keyword, attributes: [NSForegroundColorAttributeName: textColor])
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentions[section].title
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let mention = mentions[indexPath.section].data[indexPath.row]
        
        switch mention {
        case .Image(_, let ratio):
            return tableView.bounds.size.width / CGFloat(ratio)
        default:
            return UITableViewAutomaticDimension
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
