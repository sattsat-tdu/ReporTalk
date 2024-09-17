//
//  ReportChatApp.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/08/29
//  
//

import SwiftUI
import FirebaseCore

//Firebase初期化コード
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct ReportChatApp: App {
    // 追加
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
