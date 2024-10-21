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
        if await FirebaseManager.shared.checkSentFriendRequest(from: loginUser.id!, to: partnerId) {
            self.partnerState = .pendingRequest
            return
        }
        
        // 友達申請を受け取ったか判定
        if await FirebaseManager.shared.checkSentFriendRequest(from: partnerId, to: loginUser.id!) {
            self.partnerState = .pendingReceivedRequest
            return
        }

        self.partnerState = .stranger
    }
    
    //双方のフレンド追加処理
    func addFriend(userId: String) {
        UIApplication.showLoading()
        Task {
            let friendResult = await FriendManager.shared.addMutualFriends(userId: userId)
            switch friendResult {
            case .success(()):
                self.partnerState = .friend
                UIApplication.showToast(type: .success,
                                        message: "友達が増えました！")
            case .failure(let error):
                print(error.rawValue)
            }
            UIApplication.hideLoading()
        }
    }
    
    func removeFriend(userId: String) {
        UIApplication.showLoading()
        Task {
            let removeFriendResult = await FriendManager.shared.removeFriend(userId: userId)
            switch removeFriendResult {
            case .success(_):
                self.partnerState = .stranger
                UIApplication.showToast(type: .info,
                                        message: "友達を削除しました")
            case .failure(let error):
                print(error.rawValue)
            }
            UIApplication.hideLoading()
        }
    }
}
