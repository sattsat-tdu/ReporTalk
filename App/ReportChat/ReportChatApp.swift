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
    case welcomeSettings
}

@MainActor
final class Router: ObservableObject {
    @Published var selectedRoute: RouteType = .splash
    
    init() {
        self.listeningAuthChange()
    }

    func switchRootView(to routeType: RouteType) {
        withAnimation(.easeInOut) {
            self.selectedRoute = routeType
        }
    }
    
    //認証状況を確認。
    func listeningAuthChange() {
        _ = FirebaseManager.shared.auth.addStateDidChangeListener { auth, user in
            if let _ = user {
                // Firestoreにユーザー情報があるかを確認
                Task {
                    let userResult = await UserManager.shared.fetchCurrentUser()
                    switch userResult {
                    case .success(_):
                        print("Firestoreにログインユーザー情報が存在します")
                        self.switchRootView(to: .tab) // ユーザー情報が存在する場合、通常のタブ画面に遷移
                        print("ログインに成功しました(Router)")
                    case .failure(let userFetchError):
                        print(userFetchError.rawValue)
                        switch userFetchError {
                        case .authDataNotFound:
                            self.switchRootView(to: .login)
                        case .userNotFound:
                            self.switchRootView(to: .welcomeSettings) // Firestoreにユーザー情報がない場合、設定画面に遷移
                        case .networkError:
                            print("ネットワークエラー")
                        case .unknown:
                            print("Userの取得で予期せぬエラー(Router)")
                        }
                    }
                }
            } else {
                print("ログイントークンが切れています(Router)")
                self.switchRootView(to: .login)
            }
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
            Group {
                switch router.selectedRoute {
                case .splash:
                    SplashView()
                case .login:
                    WelcomeSwitchView()
                        .environmentObject(WelcomeViewModel(router: router))
                case .tab:
                    ContentView(viewModel: ContentViewModel())
                case .welcomeSettings: // WelcomeSettingsView を表示
                    WelcomeSettingsView()
                        .environmentObject(WelcomeViewModel(router: router))
                }
            }
            .animation(.easeInOut, value: router.selectedRoute)
        }
    }
}
