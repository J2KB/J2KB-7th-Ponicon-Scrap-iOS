//
//  LocalNotificationManager.swift
//  Scrap
//
//  Created by 김영선 on 2023/02/26.
//

import Foundation
import UserNotifications

struct Notification {
    var id: String
    var title: String
}

class LocalNotificationManager {
    var notifications = [Notification]()
    
    //This will request permission to show notifications,
    //and if permission is granted,
    //then schedule any existing notifications the application has created.
    func requestPermission() -> Void {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .alert]) { granted, error in
                if granted == true && error == nil {
                    print("request authorization")
                    // We have permission!
                }
        }
    }
    
    func addNotification(title: String) -> Void {
        notifications.append(Notification(id: UUID().uuidString, title: title))
    }
    
    //Now we have a way to request permission and to add some notifications
    func scheduleNotifications() -> Void {
        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = "자료 저장 완료"

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false) //1초 뒤 등장
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                guard error == nil else { return }
                print("Scheduling notification with id: \(notification.id)")
            }
        }
    }
    
    func schedule() -> Void {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestPermission()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break
            }
        }
    }
}
