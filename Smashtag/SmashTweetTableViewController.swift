//
//  SmashTweetTableViewController.swift
//  Smashtag
//
//  Created by Raymond Pau on 3/5/17.
//  Copyright © 2017 Raymond Pau. All rights reserved.
//

import UIKit
import Twitter
import CoreData

private let TweetersMentioningSearchTermSegue = "Tweeters Mentioning Search Term"
private let TweetMentionsSegue = "Tweet Mentions"

class SmashTweetTableViewController: TweetTableViewController
{
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    override func insertTweets(_ newTweets: [Twitter.Tweet]) {
        super.insertTweets(newTweets)
        updateDatabase(with: newTweets)
    }
    
    private func updateDatabase(with tweets: [Twitter.Tweet]) {
        container?.performBackgroundTask { context in
            for twitterInfo in tweets {
                _ = try? Tweet.findOrCreateTweet(matching: twitterInfo, in: context)
            }
            try? context.save()
            //self?.printDatabaseStatistics()
        }
    }
    
    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            context.perform {
                if Thread.isMainThread {
                    print("on main thread")
                } else {
                    print("off main thread")
                }
                // bad way to count
                if let tweetCount = (try? context.fetch(Tweet.fetchRequest() as NSFetchRequest<Tweet>))?.count {
                    print("\(tweetCount) tweets")
                }
                // good way to count
                if let tweeterCount = try? context.count(for: TwitterUser.fetchRequest()) {
                    print("\(tweeterCount) Twitter users")
                }
            }
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TweetersMentioningSearchTermSegue {
            if let tweetersTVC = segue.destination as? SmashTweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.container = container
            }
        } else if segue.identifier == TweetMentionsSegue {
            if let mentionsTVC = segue.destination as? MentionsTableViewController,
                let tweetTVC = sender as? TweetTableViewCell {
                mentionsTVC.tweet = tweetTVC.tweet
            }
        } else {
            return super.prepare(for: segue, sender: sender)
        }
    }
}
