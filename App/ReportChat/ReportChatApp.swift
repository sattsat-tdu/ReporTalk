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

//初期起動時に呼ばれる
class AppDelegate:NSObject,UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure() //Firebase 初期化
        return true
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
