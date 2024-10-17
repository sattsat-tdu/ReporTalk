//
//  UserManager.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/11
//  
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class UserManager: ObservableObject {
    //シングルトン
    static let shared = UserManager()
    
    private var userCache: UserResponse? = nil
    let auth: Auth
    let storage: Storage
    let fireStore: Firestore
    
    init() {
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.fireStore = Firestore.firestore()
    }
    
    //お互いのフレンズにユーザーidを追加しなければならない。
    func addFriend(userId: String) async -> Result<Void, AddIdError> {
        do {
            // 現在のユーザーを取得
            guard let loginUser = AppManager.shared.currentUser else { return .failure(.userNotFound) }
            guard let uid = loginUser.id else { return .failure(.userNotFound) }
            
            var updatedFriends = loginUser.friends
            
            if !updatedFriends.contains(userId) {
                updatedFriends.append(userId)
                
                // 自分の friends に相手を追加
                try await self.fireStore
                    .collection("users")
                    .document(uid)
                    .updateData(["friends": updatedFriends])
                
                // 相手の friends に自分を追加
                let otherUserResult = await FirebaseManager.shared.fetchUser(userId: userId)
                switch otherUserResult {
                case .success(let otherUser):
                    var otherUserFriends = otherUser.friends
                    if !otherUserFriends.contains(uid) {
                        otherUserFriends.append(uid)
                        
                        try await self.fireStore
                            .collection("users")
                            .document(userId)
                            .updateData(["friends": otherUserFriends])
                        
                        // フレンドリクエストの通知を削除
                        let snapshot = try await fireStore
                            .collection("notifications")
                            .whereField("senderId", isEqualTo: userId)
                            .whereField("receiverId", isEqualTo: uid)
                            .whereField("noticeType", isEqualTo: NoticeType.friendRequest.rawValue)
                            .getDocuments()

                        for document in snapshot.documents {
                            try await document.reference.delete()
                            print("友達を追加したため、対象のリクエストを削除しました")
                        }
                        
                        print("友達が増えました: \(userId)")
                        return .success(())
                    } else {
                        return .failure(.alreadyExists)
                    }
                case .failure(_):
                    return .failure(.otherUserNotFound)
                }
            } else {
                return .failure(.alreadyExists)
            }
        } catch {
            return .failure(.unknownError)
        }
    }
    
    // 片方のフレンドリストから相手を削除する関数
    func removeFriend(userId: String) async -> Result<Void, RemoveIdError> {
        do {
            // 現在のユーザーを取得
            guard let loginUser = AppManager.shared.currentUser else { return .failure(.userNotFound) }
            guard let uid = loginUser.id else { return .failure(.userNotFound) }
            
            var updatedFriends = loginUser.friends
            
            // 自分の friends から相手を削除
            if let index = updatedFriends.firstIndex(of: userId) {
                updatedFriends.remove(at: index)
                
                try await self.fireStore
                    .collection("users")
                    .document(uid)
                    .updateData(["friends": updatedFriends])
                
                print("友達を削除しました: \(userId)")
                return .success(())
            } else {
                return .failure(.notFound)
            }
        } catch {
            return .failure(.unknownError)
        }
    }
    
    func addRoom(roomId: String) async -> Result<Void, AddIdError> {
        do {
            guard let loginUser = AppManager.shared.currentUser else { return .failure(.userNotFound) }
            
            guard let uid = loginUser.id else { return .failure(.userNotFound) }
            var updatedRooms: [String] = loginUser.friends

            if !updatedRooms.contains(roomId) {
                updatedRooms.append(roomId)
                
                try await self.fireStore
                    .collection("users")
                    .document(uid)
                    .updateData(["rooms": updatedRooms])
                
                print("ルームが追加されました: \(roomId)")
                return .success(())
            } else {
                return .failure(.alreadyExists)
            }
        } catch {
            return .failure(.unknownError)
        }
    }
}
