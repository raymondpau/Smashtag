//
//  RecentQueriesTableViewController.swift
//  Smashtag
//
//  Created by Raymond Pau on 10/5/17.
//  Copyright © 2017 Raymond Pau. All rights reserved.
//

import UIKit

class RecentQueriesTableViewController: UITableViewController
{
    // MARK: Model
    
    var recentQueries: [String] {
        return RecentQueries.queries
    }
    
    // MARK: View
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    struct StoryBoard {
        static let KeyworkCellIdentifier = "Keyword Cell"
        static let KeywordSearchSegueIdentifier = "Keyword Search"
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentQueries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryBoard.KeyworkCellIdentifier, for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = recentQueries[indexPath.row]
        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            RecentQueries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == StoryBoard.KeywordSearchSegueIdentifier {
            if let destination = (segue.destination as? SmashTweetTableViewController),
                let cell = sender as? UITableViewCell {
                destination.searchText = cell.textLabel?.text
            }
        }
    }
}
