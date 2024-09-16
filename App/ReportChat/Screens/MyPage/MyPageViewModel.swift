//
//  MyPageViewModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import Foundation

@MainActor
final class MyPageViewModel: ObservableObject {
    
    @Published var currentUser: UserResponse?
    
    init() {
        self.fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.currentUser else {
            print("エラーです。。。。")
            return
        }
        Task {
            let currentUserResponse = await FirebaseManager.shared.fetchUser(userId: uid)
            if let user = currentUserResponse {
                self.currentUser = user
            }
        }
    }
}
