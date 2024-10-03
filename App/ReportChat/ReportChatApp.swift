//
//  ReportChatApp.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/08/29
//  
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

enum RouteType: Equatable {
    case splash
    case login
    case tab
}

@MainActor
final class Router: ObservableObject {
    @Published var selectedRoute: RouteType = .splash
    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        self.startListeningAuthChange()
    }

    func switchRootView(to routeType: RouteType) {
        withAnimation(.easeInOut) {
            self.selectedRoute = routeType
        }
    }
    
    func startListeningAuthChange() {
        if authListenerHandle == nil {
            authListenerHandle = FirebaseManager.shared.auth.addStateDidChangeListener { auth, user in
                if let _ = user {
                    print("ログインに成功しました(Router)")
                    self.switchRootView(to: .tab)
                } else {
                    print("ログイントークンが切れています(Router)")
                    self.switchRootView(to: .login)
                }
            }
        }
    }
    
    func stopListeningAuthChange() {
        if let handle = authListenerHandle {
            FirebaseManager.shared.auth.removeStateDidChangeListener(handle)
            authListenerHandle = nil
        }
    }
}


@main
struct ReportChatApp: App {
    
    @StateObject private var router = Router()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            switch router.selectedRoute {
            case .splash:
                SplashView()
            case .login:
                WelcomeSwitchView()
                    .environmentObject(WelcomeViewModel(router: router))
            case .tab:
                ContentView()
            }
        }
    }
}
