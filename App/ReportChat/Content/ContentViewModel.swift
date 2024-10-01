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
            let currentUserResult = await FirebaseManager.shared.fetchUser(userId: uid)
            switch currentUserResult {
            case .success(let user):
                self.roomsViewModel = RoomsViewModel(user: user)
                self.currentUser = user
            case .failure(let userFetchError):
                UIApplication.showModal(
                    modalItem: ModalItem(
                        type: .error,
                        title: userFetchError.rawValue,
                        description: userFetchError.errorDescription,
                        alignment: .center,
                        isCancelable: false,
                        onTapped: {
                            switch userFetchError {
                            case .userNotFound:
                                Task { //再ログインの促し
                                    await FirebaseManager.shared.handleLogout()
                                }
                            case .unknown:
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.fetchCurrentUser()  // 再試行
                                }
                            }
                        }
                    )
                )
            }
        }
    }
}
