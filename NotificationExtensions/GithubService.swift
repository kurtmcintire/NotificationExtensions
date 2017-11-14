//
//  GithubService.swift
//  NotificationExtensions
//
//  Created by Kurt McIntire on 11/13/17.
//  Copyright © 2017 KurtMcIntire. All rights reserved.
//

import UIKit

struct GithubService {

    static func getData(completion: @escaping (_ repos: [Repo]?, _ error: Error?) -> Void) {
        
        let defaultSession = URLSession(configuration: .default)
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        
        let urlString: String = "https://api.github.com/orgs/apple/repos"
        guard let url = URL(string: urlString) else { return }
        let urlRequest = URLRequest.init(url: url)
        
        let task = defaultSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            if let unwrappedError = error {
                print(unwrappedError)
                completion(nil, unwrappedError)
            }
            
            if let unwrappedData = data {
                let decoder = JSONDecoder()
                let repos = try! decoder.decode([Repo].self, from: unwrappedData)
                completion(repos, nil)
            }
            
        })
        task.resume()
    }
}
