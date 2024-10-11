//
//  ContentViewModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/19
//  
//

import Foundation
import UIKit

@MainActor
final class ContentViewModel: ObservableObject {
    @Published var currentUser: UserResponse? = nil
    @Published var roomsViewModel: RoomsViewModel?  // RoomsViewModelを保持

    init() {
        self.onAppear()
    }
    
    func onAppear() {
        Task {
            let userResult = await UserManager.shared.fetchCurrentUser()
            switch userResult {
            case .success(let currentUser):
                self.roomsViewModel = RoomsViewModel(user: currentUser)
                self.currentUser = currentUser
            case .failure(let error):
                FirebaseError.shared.showErrorToast(error)
            }
        }
    }
}
