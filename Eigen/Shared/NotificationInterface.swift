//
// NotificationInterface.swift
// Eigen
//
        

import Foundation
import UserNotifications
import AppKit

func sendNotification(id: String, title: String, body: String, trigger: UNNotificationTrigger? = nil) {
    let notificationCenter = UNUserNotificationCenter.current()

    notificationCenter.getNotificationSettings { notificationSettings in
        switch notificationSettings.authorizationStatus {
        case .notDetermined:
            notificationCenter.requestAuthorization(options: [.alert, .badge]) { granted, _ in
                if granted {
                    _sendNotification(id: id, title: title, body: body, trigger: trigger)
                }
            }
        case .authorized, .provisional:
            _sendNotification(id: id, title: title, body: body, trigger: trigger)
        case .denied:
            return
        default:
            return
        }
    }
}

private func _sendNotification(id: String, title: String, body: String, trigger: UNNotificationTrigger? = nil) {
    let notificationCenter = UNUserNotificationCenter.current()

    let notificationContent = UNMutableNotificationContent()
    notificationContent.title = title
    notificationContent.body = body
//    notificationContent.badge = 1

    notificationCenter.add(UNNotificationRequest(identifier: id, content: notificationContent, trigger: trigger))
}

func clearAllNotifications() {
    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
}
