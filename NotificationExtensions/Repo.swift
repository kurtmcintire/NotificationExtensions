//
//  Repo.swift
//  NotificationExtensions
//
//  Created by Kurt McIntire on 11/13/17.
//  Copyright © 2017 KurtMcIntire. All rights reserved.
//

struct Repo: Codable {
    
    //  "id": 44137852,
    // "name": "cups",
    // "full_name": "apple/cups",
    
    var objectId: Int
    var name: String
    var fullName: String
    
    init(objectId: Int, name: String, fullName: String) {
        self.objectId = objectId
        self.name = name
        self.fullName = fullName
    }
}

extension Repo {
    enum RepoKeys : String, CodingKey {
        case objectId = "id"
        case name = "name"
        case fullName = "full_name"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RepoKeys.self) // defining our (keyed) container
        let objectId: Int = try container.decode(Int.self, forKey: .objectId)
        let name: String = try container.decode(String.self, forKey: .name)
        let fullName: String = try container.decode(String.self, forKey: .fullName)
        self.init(objectId: objectId, name: name, fullName: fullName)
    }
}
