//
//  AppDelegate.swift
//  NotificationExtensions
//
//  Created by Kurt McIntire on 11/13/17.
//  Copyright © 2017 KurtMcIntire. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in }
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func scheduleNotification() {
        
        let downloadAction = UNNotificationAction(identifier: "DOWNLOAD_ACTION",
                                                  title: "Download",
                                                  options: UNNotificationActionOptions(rawValue: 0))
        
        let dismissAction = UNNotificationAction(identifier: "DISMISS_ACTION",
                                                 title: "Dismiss",
                                                 options: UNNotificationActionOptions(rawValue: 0))
        
        let downloadCategory = UNNotificationCategory(identifier: "DOWNLOAD_CATEGORY",
                                                     actions: [downloadAction, dismissAction],
                                                     intentIdentifiers: [],
                                                     options: UNNotificationCategoryOptions(rawValue: 0))
        
        // Register the notification categories.
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([downloadCategory])
        
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.categoryIdentifier = "DOWNLOAD_CATEGORY"
        notificationContent.title = "New Download Available"
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: false)
        let notificationRequest = UNNotificationRequest(identifier: "specialIdentifier", content: notificationContent, trigger: notificationTrigger)
        
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                return
            }
            
            print("Successfully Added Notification Request")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Received: Foreground Notification")
        downloadData()
        completionHandler([.alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Received: Background Notification")
        
        if response.notification.request.content.categoryIdentifier == "DOWNLOAD_CATEGORY" {
            if response.actionIdentifier == "DOWNLOAD_ACTION" {
                print("Action: Download pressed")
                downloadData()
                
            } else if response.actionIdentifier == "DISMISS_ACTION" {
                print("Action: Dismiss pressed")
            }
        }
        
        completionHandler()
    }
    
    fileprivate func downloadData() {
        GithubService.getData(completion: { (repos, error) in
            DispatchQueue.main.async {
                let dateformatter = DateFormatter()
                dateformatter.dateStyle = .short
                dateformatter.timeStyle = .long
                let nowString = dateformatter.string(from: Date())
                TimestampService.saveNewData(string: nowString)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Notification.RefreshLocalData"), object: nil)
            }
        })
    }
}

