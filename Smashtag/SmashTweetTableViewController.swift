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

class SmashTweetTableViewController: TweetTableViewController
{
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    override func insertTweets(_ newTweets: [Twitter.Tweet]) {
        super.insertTweets(newTweets)
        updateDatabase(with: newTweets)
    }
    
    private func updateDatabase(with tweets: [Twitter.Tweet]) {
        print("starting database load")
        container?.performBackgroundTask { [weak self] context in
            for twitterInfo in tweets {
                _ = try? Tweet.findOrCreateTweet(matching: twitterInfo, in: context)
            }
            try? context.save()
            print("done loading database")
            self?.printDatabaseStatistics()
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
    
    private struct StoryBoard {
        static let TweetersMentioningSearchTermSegue = "Tweeters Mentioning Search Term"
        static let TweetMentionsSegue = "Tweet Mentions"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryBoard.TweetersMentioningSearchTermSegue {
            if let tweetersTVC = segue.destination as? SmashTweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.container = container
            }
        } else if segue.identifier == StoryBoard.TweetMentionsSegue {
            if let mentionsTVC = segue.destination as? MentionsTableViewController,
                let tweetTVC = sender as? TweetTableViewCell {
                mentionsTVC.tweet = tweetTVC.tweet
            }
        }
    }
}
