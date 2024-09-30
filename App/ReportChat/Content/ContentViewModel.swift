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
            let currentUserResponse = await FirebaseManager.shared.fetchUser(userId: uid)
            if let user = currentUserResponse {
                self.roomsViewModel = RoomsViewModel(user: user) 
                self.currentUser = user
            }
            else {
                print("FireStoreが上限突破した可能性があります。不明なエラーとかしよかな")
                UIApplication.showModal(
                    modalItem: ModalItem(
                        type: .error,
                        title: "サーバーエラー",
                        description: "サーバー側で何らかの問題が発生しています。\nお手数おかけしますが、後でもう一度お試しください。\nリトライしますか？",
                        alignment: .center,
                        isCancelable: false,
                        onTapped: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self.fetchCurrentUser()  // 再試行
                            }
                        }
                    )
                )
            }
        }
    }
}
