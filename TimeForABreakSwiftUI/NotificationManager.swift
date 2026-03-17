//
//  NotificationManager.swift
//  TimeForABreakSwiftUI
//
//  Created by Chris Duehrsen on 2022-04-07.
//

import Combine
import Foundation
import UserNotifications
import SwiftUI

/// Thin wrapper around `UNUserNotificationCenter` used by the app to schedule and inspect
/// local timer-completion notifications.
final class NotificationManager : ObservableObject {
    @Published private(set) var notifications : [UNNotificationRequest] = []
    @Published private(set) var authorizationStatus :  UNAuthorizationStatus?
    
    func reloadAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    func requestAuth() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound ]) { isGranted, _ in
            DispatchQueue.main.async {
                self.authorizationStatus = isGranted ? .authorized : .denied
            }
        }
    }
    
    func reloadLocNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            DispatchQueue.main.async {
                self.notifications = notifications
            }
        }
    }
    
    func createLocalNotification(title: String, body: String, secondsUntilDone: Int, doesPlaySounds: Bool = false, completion: @escaping (Error?)-> Void ) {
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(secondsUntilDone), repeats: false)
        
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = title
        notificationContent.body = body
        if doesPlaySounds {
            notificationContent.sound = UNNotificationSound.default
        }
        
        let request = UNNotificationRequest(identifier: "timeIntervalLapsed", content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: completion)
        
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
}
