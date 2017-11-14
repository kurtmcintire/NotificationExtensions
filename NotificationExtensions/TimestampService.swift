//
//  TimestampService.swift
//  NotificationExtensions
//
//  Created by Kurt McIntire on 11/13/17.
//  Copyright © 2017 KurtMcIntire. All rights reserved.
//

import Foundation

struct TimestampService {
    
    static func loadData() -> [String] {
        
        let defaults = UserDefaults.standard
        
        if let array = defaults.object(forKey: "savedStrings") as? [String] {
            return array
        } else {
            return []
        }
    }
    
    static func saveNewData(string: String) {
        var array = loadData()
        array.append(string)
        saveData(strings: array)
    }
    
    fileprivate static func saveData(strings: [String]) {
        let defaults = UserDefaults.standard
        defaults.set(strings, forKey: "savedStrings")
    }
}
