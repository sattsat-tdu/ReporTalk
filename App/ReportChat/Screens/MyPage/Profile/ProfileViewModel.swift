//
//  ProfileViewModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/26
//  
//


import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    
    let user: UserResponse
    @Published var userName: String
    
    init(user: UserResponse) {
        self.user = user
        self.userName = user.userName
    }
    
    func logout() {
        Task {
            await FirebaseManager.shared.handleLogout()
        }
    }
}
