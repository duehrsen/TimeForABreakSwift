//
//  NotificationManager.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-07.
//

import Foundation
import UserNotifications

final class NotificationManager : ObservableObject {
    @Published private(set) var notifications : [UNNotificationRequest] = []
    @Published private(set) var authorizationStatus :  UNAuthorizationStatus?
    
    func reloadAuthorizationStatus() {
        print("Reloading auth for notif")
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    func requestAuth() {
        print("Requesting auth for notif")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound ]) { isGranted, _ in
            DispatchQueue.main.async {
                self.authorizationStatus = isGranted ? .authorized : .denied
            }
        }
    }
    
    func reloadLocNotifications() {
        print("Reloading local notifications")
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            DispatchQueue.main.async {
                self.notifications = notifications
            }
        }
    }
    
    func createLocalNotification(title: String, secondsUntilDone: Int, completion: @escaping (Error?)-> Void ) {
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
        
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = title
        notificationContent.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "timeIntervalLapsed", content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: completion)
        
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func printNotificationTimeIntervals() {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
        for request in requests {
            let thisTrigger = request.trigger as? UNTimeIntervalNotificationTrigger
            print(thisTrigger?.nextTriggerDate()?.timeIntervalSinceNow ?? "")
        }})
    }
}
