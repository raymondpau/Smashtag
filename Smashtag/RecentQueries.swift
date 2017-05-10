//
//  RecentQueries.swift
//  Smashtag
//
//  Created by Raymond Pau on 10/5/17.
//  Copyright © 2017 Raymond Pau. All rights reserved.
//

import Foundation

struct RecentQueries
{
    private static let defaults = UserDefaults.standard
    
    private struct Constants {
        static let key = "RecentQueries"
        static let limit = 100
    }
    
    static var queries: [String] {
        return (defaults.object(forKey: Constants.key) as? [String]) ?? []
    }
    
    static func add(_ keyword: String) {
        // Remove old keyword from queries if it exist
        var newQueries = queries.filter { keyword.caseInsensitiveCompare($0) != .orderedSame }
        // Add keyword to the start of array
        newQueries.insert(keyword, at: 0)
        
        if newQueries.count > Constants.limit {
            newQueries.removeSubrange((Constants.limit)..<(newQueries.count))
        }
        defaults.set(newQueries, forKey: Constants.key)
    }
    
    static func remove(at index: Int) {
        var newQueries = (defaults.object(forKey: Constants.key) as? [String]) ?? []
        newQueries.remove(at: index)
        defaults.set(newQueries, forKey: Constants.key)
    }
}
