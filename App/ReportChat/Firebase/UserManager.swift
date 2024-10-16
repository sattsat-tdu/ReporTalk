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
    
    //二重タスクを防ぐ（サーバーへの通信を抑える）
    private var currentFetchTask: Task<Result<UserResponse, UserFetchError>, Never>? = nil
    
    // ユーザー情報の取得 (進行中のリクエストを管理)
    func fetchCurrentUser() async -> Result<UserResponse, UserFetchError> {
        // キャッシュがあればそれを返す
        if let cachedUser = userCache {
            print("キャッシュからユーザー情報を取得しました")
            return .success(cachedUser)
        }

        // 進行中のリクエストがあればそのタスクを待機する
        if let currentFetchTask = currentFetchTask {
            print("リクエストが進行中のため、その結果を待っています")
            return await currentFetchTask.value
        }

        // 新しいリクエストを開始
        let fetchTask = Task { () -> Result<UserResponse, UserFetchError> in
            defer {
                // タスク完了後に必ずタスク変数をクリア
                self.currentFetchTask = nil
            }
            
            do {
                guard let uid = self.auth.currentUser?.uid else {
                    return .failure(.authDataNotFound)
                }
                let snapshot = try await self.fireStore
                    .collection("users")
                    .document(uid)
                    .getDocument()

                guard snapshot.exists else {
                    print("ユーザーIDがFirestoreに存在しません")
                    return .failure(.userNotFound)
                }

                print("ログインユーザー情報の取得に成功しました")
                let userResponse = try snapshot.data(as: UserResponse.self)
                // キャッシュに保存
                self.userCache = userResponse

                return .success(userResponse)
            } catch let error as NSError {
                if error.domain == NSURLErrorDomain {
                    print("ネットワークに接続できません: \(error.localizedDescription)")
                    return .failure(.networkError)
                } else {
                    print("ユーザーデータの取得中にその他のエラーが発生しました: \(error.localizedDescription)")
                    return .failure(.unknown)
                }
            }
        }

        // 現在進行中のリクエストとして保存
        currentFetchTask = fetchTask

        // リクエストの結果を返す
        return await fetchTask.value
    }
    
    // キャッシュをクリアするメソッド（ログアウトやデータ変更時に呼び出す）
    func clearUserCache() {
        self.userCache = nil
        self.currentFetchTask = nil // 進行中のリクエストもクリア
    }
    
    //お互いのフレンズにユーザーidを追加しなければならない。
    func addFriend(userId: String) async -> Result<Void, AddIdError> {
        do {
            // 現在のユーザーを取得
            guard case let .success(loginUser) = await self.fetchCurrentUser() else { return .failure(.userNotFound) }
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
            guard case let .success(loginUser) = await self.fetchCurrentUser() else { return .failure(.userNotFound) }
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
            guard case let .success(loginUser) = await self.fetchCurrentUser() else { return .failure(.userNotFound) }
            
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
