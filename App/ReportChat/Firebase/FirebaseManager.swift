//
//  FirebaseManager.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/08/31
//  
//

import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class FirebaseManager: ObservableObject {
    //どこでも共有させる。
    static let shared = FirebaseManager()
    
    let auth: Auth
    let storage: Storage
    let fireStore: Firestore
    var currentUser: String? {
        return auth.currentUser?.uid
    }
    
    init() {
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.fireStore = Firestore.firestore()
    }
    
    //idからユーザー情報を取得
    @MainActor
    func fetchUser(userId: String) async -> UserResponse? {
        do {
            let snapshot = try await 
            FirebaseManager.shared.fireStore
                .collection("users")
                .document(userId)
                .getDocument()
            
            if let data = snapshot.data() {
                return UserResponse.init(data: data)
            } else {
                print("データの変換に失敗")
                return nil
            }
        } catch let error as NSError {
            print("ユーザーが見つかりませんでした。")
            return nil
        }
    }
}
