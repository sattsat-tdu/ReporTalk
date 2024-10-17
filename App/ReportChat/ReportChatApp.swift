//
//  ReportChatApp.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/08/29
//  
//

import SwiftUI
import FirebaseCore

@main
struct ReportChatApp: App {
    
    @StateObject private var router = Router()
    @StateObject private var appManager = AppManager.shared
    
    init() {
        FirebaseApp.configure()
    }
    
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
                    ContentView()
                        .environmentObject(appManager)
                case .welcomeSettings: // WelcomeSettingsView を表示
                    WelcomeSettingsView()
                        .environmentObject(WelcomeViewModel(router: router))
                }
            }
            .animation(.easeInOut, value: router.selectedRoute)
        }
    }
}
