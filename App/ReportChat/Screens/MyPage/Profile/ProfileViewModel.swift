//
//  ProfileViewModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/26
//  
//


import Foundation
import UIKit

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
    
    func deleteUser() {
        guard let currentUser = FirebaseManager.shared.auth.currentUser else { return }
        UIApplication.showLoading(message: "データを削除中です...")
        let userId = currentUser.uid
        
        Task {
            //FireStoreの"users"からアカウント削除
            await FirebaseManager.shared.deleteUserData(userId: userId)
            
            //設定していたアイコンを削除
            await FirebaseManager.shared.deleteUserImage(userId: userId)
            
            //最後にUser認証情報を削除
            await FirebaseManager.shared.deleteAuthUser(deleteUser: currentUser)
            
            UIApplication.hideLoading()
        }
    }
}
