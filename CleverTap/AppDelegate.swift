//
//  AppDelegate.swift
//  CleverTap
//
//  Created by huyoi on 18/4/26.
//

import UIKit
import CleverTapSDK
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        // Init CleverTap
        CleverTap.autoIntegrate()

        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self

        // Handle app opened from push (cold start)
        if let notification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            CleverTap.sharedInstance()?.handleNotification(withData: notification)
        }

        // Request permission
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            print("DEVLOG: Permission:", granted)

            if let error = error {
                print("DEVLOG: Permission error:", error.localizedDescription)
            }

            if granted {
                DispatchQueue.main.async {
                    print("DEVLOG: Registering for remote notifications...")
                    application.registerForRemoteNotifications()
                }
            }
        }

        return true
    }

    // MARK: - Device Token
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("DEVLOG: DeviceToken:", tokenString)

        CleverTap.sharedInstance()?.setPushToken(deviceToken)
    }

    // MARK: - Fail
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("DEVLOG: Push register failed:", error.localizedDescription)
    }

    // MARK: - Receive push (background / silent)
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("DEVLOG: Received push (background):", userInfo)
        CleverTap.sharedInstance()?.recordNotificationViewedEvent(withData: userInfo)
        CleverTap.sharedInstance()?.handleNotification(withData: userInfo)
        completionHandler(.noData)
    }

    // MARK: - Receive push (foreground)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        print("DEVLOG: Received push (foreground):", userInfo)
        CleverTap.sharedInstance()?.recordNotificationViewedEvent(withData: userInfo)
        completionHandler([.banner, .sound, .badge])
    }

    // MARK: - User tapped on push
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        CleverTap.sharedInstance()?.recordNotificationClickedEvent(withData: userInfo)

        CleverTap.sharedInstance()?.handleNotification(withData: userInfo)

        completionHandler()
    }
}
