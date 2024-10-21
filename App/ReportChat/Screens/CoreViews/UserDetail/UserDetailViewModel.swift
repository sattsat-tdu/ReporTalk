//
//  UserDetailViewModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/16
//  
//

import Foundation
import UIKit

//自分と相手のプロフィールを管理
enum PartnerState {
    case selfProfile // 自分のプロフィール
    case friend      // 友達
    case pendingRequest // 友達申請中
    case pendingReceivedRequest //友達申請を受けている状態
    case stranger    // 他人
}

@MainActor
class UserDetailViewModel: ObservableObject {
    @Published var partnerState: PartnerState? = nil
    
    func checkPartnerState(for user: UserResponse) async {
        guard let loginUser = AppManager.shared.currentUser else { return }
        guard let partnerId = user.id else { return }

        // 自分のプロフィールか判定
        if loginUser.id == partnerId {
            self.partnerState = .selfProfile
            return
        }
        
        // 友達か判定
        if loginUser.friends.contains(partnerId) {
            self.partnerState = .friend
            return
        }
        
        // 友達申請を送ったか判定
        if await NotificationManager.shared.checkSentFriendRequest(from: loginUser.id!, to: partnerId) {
            self.partnerState = .pendingRequest
            return
        }
        
        // 友達申請を受け取ったか判定
        if await NotificationManager.shared.checkSentFriendRequest(from: partnerId, to: loginUser.id!) {
            self.partnerState = .pendingReceivedRequest
            return
        }

        self.partnerState = .stranger
    }
    
    //双方のフレンド追加処理
    func addFriend(to user: UserResponse) {
        UIApplication.showLoading()
        guard let loginUser = AppManager.shared.currentUser else { return }
        Task {
            let friendResult = await FriendManager.shared.addMutualFriends(userId: user.id!)
            switch friendResult {
            case .success(()):
                NotificationManager.shared.sendAnnouncement(to: user.id!,
                                                            message: "「\(loginUser.userName)」が友達申請を承認しました！")
                self.partnerState = .friend
                UIApplication.showToast(type: .success, message: "「\(user.userName)」と友達になりました！")
            case .failure(let error):
                print(error.rawValue)
            }
            UIApplication.hideLoading()
        }
    }
    
    func removeFriend(to user: UserResponse) {
        UIApplication.showLoading()
        Task {
            let removeFriendResult = await FriendManager.shared.removeFriend(userId: user.id!)
            switch removeFriendResult {
            case .success(_):
                self.partnerState = .stranger
                UIApplication.showToast(type: .info, message: "「\(user.userName)」を友達から削除しました")
            case .failure(let error):
                print(error.rawValue)
            }
            UIApplication.hideLoading()
        }
    }
    
    func sendFriendRequest(to user: UserResponse) {
        guard let loginUser = AppManager.shared.currentUser else { return }
        //すでに相手側にフレンド追加されているか確認
        if user.friends.contains(loginUser.id!) {
            UIApplication.showLoading()
            Task {
                let result = await FriendManager.shared.addFriend(fromUser: loginUser, toId: user.id!)
                switch result {
                case .success(_):
                    self.partnerState = .friend
                    UIApplication.showToast(type: .success, message: "「\(user.userName)」と友達になりました！")
                case .failure(let error):
                    print("\(error.rawValue)")
                }
                UIApplication.hideLoading()
            }
        } else {
            NotificationManager.shared.sendFriendRequestNotification(to: user.id!)
            self.partnerState = .pendingRequest
            UIApplication.showToast(type: .info, message: "「\(user.userName)」に友達申請を送りました")
        }
    }
}
