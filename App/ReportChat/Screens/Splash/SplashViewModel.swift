//
//  SplashViewModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import Foundation

@MainActor
final class SplashViewModel: ObservableObject {
    
    private let router: Router

    init(router: Router) {
        self.router = router
        self.checkLoginStatus()
    }
    
    func checkLoginStatus() {
        _ = FirebaseManager.shared.auth.addStateDidChangeListener { auth, user in
             if let _ = user {
                 print("ログインに成功しました(SplashViewModel)")
                 self.router.selectedRoute = .tab
             } else {
                 print("ログイントークンが切れています(SplashViewModel)")
                 self.router.selectedRoute = .login
             }
         }
    }
}
