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
}
