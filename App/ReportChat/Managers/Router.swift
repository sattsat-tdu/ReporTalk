//
//  Router.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/17
//  
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

enum RouteType: Equatable {
    case splash
    case login
    case tab
    case welcomeSettings
}

@MainActor
final class Router: ObservableObject {
    @Published var selectedRoute: RouteType = .splash
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    init() {
        self.listeningAuthChange()
    }

    func switchRootView(to routeType: RouteType) {
        withAnimation(.easeInOut) {
            self.selectedRoute = routeType
        }
    }
    
    // 認証状況を確認。
    func listeningAuthChange() {
        _ = auth.addStateDidChangeListener { auth, user in
            if let user = user {
                // Firestoreにユーザー情報があるかを確認
                self.firestore.collection("users")
                    .document(user.uid)
                    .getDocument { snapshot, error in
                        if let error = error {
                            print("Firestoreのユーザー取得エラー(AuthListener): \(error.localizedDescription)")
                            return
                        }
                        
                        if let snapshot = snapshot, snapshot.exists {
                            print("ログインユーザーの情報が存在します(AuthListener)")
                            //ログインに成功したらUser情報を監視
                            AppManager.shared.listenToUserUpdates()
                            self.switchRootView(to: .tab)
                        } else {
                            // Firestoreにユーザー情報が存在しない場合、設定画面に遷移
                            print("Auth情報の取得に成功したものの、DBに存在しません(AuthListener)")
                            self.switchRootView(to: .welcomeSettings)
                        }
                    }
            } else {
                print("ログインしていません(AuthListener)")
                self.switchRootView(to: .login)
            }
        }
    }
}
