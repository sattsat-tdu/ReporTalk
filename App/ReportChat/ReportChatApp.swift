//
//  ReportChatApp.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/08/29
//
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseMessaging
import UserNotifications

//初期起動時に呼ばれる
class AppDelegate:NSObject,UIApplicationDelegate, MessagingDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure() //Firebase 初期化
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // APNsトークンをFirebaseに設定
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
                print("[DEBUG] FCM Tokenの取得に失敗: \(error)")
            } else if let token = token {
                UDManager.shared.set(token, forKey: AppStateKeys.fcmToken)
                Task {  //ユーザーが許可したタイミングで追加
                    await UserServiceManager.shared.addFCMToken(token: token)
                    print("[DEBUG] FCM Tokenの取得に成功: \(token)")
                }
            }
        }
    }
}

// MARK: - AppDelegate Push Notification
extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo["gcm.message_id"] {
            print("MessageID: \(messageID)")
        }
        print(userInfo)
        completionHandler(.newData)
    }
    
    // アプリを開いている時にもPush通知を受信する処理
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

@main
struct ReportChatApp: App {
    
    @StateObject private var router = Router()
    @StateObject private var appManager = AppManager.shared
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    //SwiftData使用の宣言
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ReporTagMessage.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch router.selectedRoute {
                case .splash:
                    SplashView()
                case .login:
                    WelcomeSwitchView()
                        .environmentObject(WelcomeViewModel(router: router))
                case .tab:
                    if appManager.currentUser != nil {
                        ContentView()
                            .environmentObject(appManager)
                    } else {
                        SplashView()
                    }
                case .welcomeSettings: // WelcomeSettingsView を表示
                    WelcomeSettingsView()
                        .environmentObject(WelcomeViewModel(router: router))
                }
            }
            .animation(.easeInOut, value: router.selectedRoute)
        }
        .modelContainer(sharedModelContainer)   //SwiftDataの使用
    }
}
