//
//  TableViewController.swift
//  NotificationExtensions
//
//  Created by Kurt McIntire on 11/13/17.
//  Copyright © 2017 KurtMcIntire. All rights reserved.
//

import UIKit
import UserNotifications

class TableViewController: UITableViewController {

    
    //# MARK: - Instance Properties
    
    var dataSource: [String] = []
    
    lazy var emptyView: UIView = {
        let view = UIView.init(frame: UIScreen.main.bounds)        
        let label = UILabel.init(frame: view.frame)
        label.text = "No Data"
        label.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        label.textColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        label.textAlignment = .center
        view.addSubview(label)
        
        return view
    }()
    
    
    //# MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Extension Inbox"
        setupObservers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    
    //# MARK: - IBActions
    
    @IBAction func addButtonPressed(_ sender: Any) {
        attemptScheduleNotification()
    }
    
    
    //# MARK: - Public Selectors
    
    @objc func appMovedToForeground() {
        loadData()
    }
    
    @objc func refreshLocalData() {
        loadData()
    }
    
    
    //# MARK: - Private Functions
    
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLocalData), name: NSNotification.Name(rawValue: "Notification.RefreshLocalData"), object: nil)
    }
    
    fileprivate func loadData() {
        dataSource = TimestampService.loadData()
        updateDataSource()
    }
    
    fileprivate func attemptScheduleNotification() {
        UNUserNotificationCenter.current().getNotificationSettings { [unowned self] (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestNotifications()
            case .authorized:
                self.scheduleNotification()
            case .denied:
                self.showDeniedAlert()
            }
        }
    }
    
    fileprivate func scheduleNotification() {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.scheduleNotification()
        }
    }
    
    fileprivate func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (success, error) in })
    }
    
    fileprivate func showDeniedAlert() {
        let alert = UIAlertController.init(title: "Alerts Denied", message: "See Settings to update preferences", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func updateDataSource() {
        
        if dataSource.isEmpty {
            tableView.separatorStyle = .none
            view.addSubview(emptyView)
        } else {
            tableView.separatorStyle = .singleLine
            emptyView.removeFromSuperview()
        }
        
        tableView.reloadData()
    }

    
    //# MARK: - UITableViewController

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomCell else {
            return UITableViewCell()
        }
        
        let item = dataSource[indexPath.row]
        cell.mainLabel.text = item
        cell.subtitleLabel.text = "Last Download"
        return cell
    }
}
