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

enum RouteType: Equatable {
    case splash
    case login
    case tab
}

@MainActor
final class Router: ObservableObject {
    @Published var selectedRoute: RouteType = .splash

    func switchRootView(to routeType: RouteType) {
        selectedRoute = routeType
    }

}


@main
struct ReportChatApp: App {
    // 追加
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @ObservedObject private var router = Router()
    
    var body: some Scene {
        WindowGroup {
            switch router.selectedRoute {
            case .splash:
                SplashView(viewModel: SplashViewModel(router: router))
            case .login:
                WelcomeView()
                    .environmentObject(WelcomeViewModel(router: router))
            case .tab:
                ContentView()
            }
            
        }
    }
}
