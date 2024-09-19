//
//  ContentViewModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/19
//  
//

import Foundation

@MainActor
final class ContentViewModel: ObservableObject {
    @Published var currentUser: UserResponse?
    @Published var roomsViewModel: RoomsViewModel?  // RoomsViewModelを保持
    
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
                self.roomsViewModel = RoomsViewModel(user: user) 
                self.currentUser = user
            }
        }
    }
}
