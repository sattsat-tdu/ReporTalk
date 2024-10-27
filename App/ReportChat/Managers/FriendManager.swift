//
//  FriendManager.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/10/21
//
//

import FirebaseFirestore

final class FriendManager {
    static let shared = FriendManager()
    private let firestore = Firestore.firestore()
    
    private init() {}
    
    //双方のfriendsにuserIdを追加
    func addMutualFriends(userId: String) async -> Result<Void, FriendManagerError> {
        // ログインユーザー情報を取得
        guard let loginUser = AppManager.shared.currentUser,
              let loginUserId = loginUser.id else { return .failure(.userNotFound) }
        
        let otherUserResult = await FirebaseManager.shared.fetchUser(userId: userId)
        guard case .success(let otherUser) = otherUserResult else { return .failure(.otherUserNotFound) }
        
        //ログインユーザーのfriends追加
        let addFriendResult = await addFriend(fromUser: loginUser, toId: userId)
        if case .failure(let error) = addFriendResult {
            return .failure(error)
        }
        
        //引数ユーザーのfriends追加
        let addCurrentUserResult = await addFriend(fromUser: otherUser, toId: loginUserId)
        if case .failure(let error) = addCurrentUserResult {
            return .failure(error)
        }
        await removeFriendRequestNotification(from: userId, to: loginUserId)
        return .success(())
    }
    
    // 片方のフレンドリストから相手を削除する関数
    func removeFriend(userId: String) async -> Result<Void, FriendManagerError> {
        // ログインユーザー情報を取得
        guard let loginUser = AppManager.shared.currentUser,
              let loginUserId = loginUser.id else { return .failure(.userNotFound) }
        
        var updatedFriends = loginUser.friends

        // 自分の friends から相手を削除
        if let index = updatedFriends.firstIndex(of: userId) {
            updatedFriends.remove(at: index)
            let updateResult = await updateFriends(userId: loginUserId, data: updatedFriends)
            switch updateResult {
            case .success(_):
                return .success(())
            case .failure(let error):
                return .failure(error)
            }
        } else {
            return .failure(.userNotFound)
        }
    }
    
    //fromUserのfriendsに指定のuserIdを追加する関数
    func addFriend(fromUser: UserResponse, toId: String) async -> Result<Void, FriendManagerError> {
        guard let uid = fromUser.id else { return .failure(.userNotFound) }
        
        var updatedFriends: [String] = fromUser.friends
        
        if !updatedFriends.contains(toId) {
            updatedFriends.append(toId)
            
            let updateResult = await updateFriends(userId: uid, data: updatedFriends)
            switch updateResult {
            case .success(_):
                return .success(())
            case .failure(let error):
                return .failure(error)
            }
        } else {
            return .failure(.alreadyExists)
        }
    }
    
    //友達リストを更新する
    private func updateFriends(userId: String, data: [String]) async -> Result<Void, FriendManagerError> {
        do {
            try await firestore
                .collection("users")
                .document(userId)
                .updateData(["friends": data])
            return .success(())
        } catch {
            print("フレンドリストの更新に失敗(FriendManager): \(error.localizedDescription)")
            return .failure(.updateFailed)
        }
    }
    
    //リクエスト通知を削除する
    private func removeFriendRequestNotification(from senderId: String, to receiverId: String) async {
        do {
            let snapshot = try await firestore
                .collection("notifications")
                .whereField("senderId", isEqualTo: senderId)
                .whereField("receiverId", isEqualTo: receiverId)
                .whereField("noticeType", isEqualTo: NoticeType.friendRequest.rawValue)
                .getDocuments()

            for document in snapshot.documents {
                try await document.reference.delete()
            }
        } catch {
            print("リクエスト通知の削除に失敗(FriendManager): \(error.localizedDescription)")
        }
    }
}
