//
//  AppManager.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/10/16
//
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AppManager: ObservableObject {
    static let shared = AppManager()
    
    @Published var currentUser: UserResponse?
    private let firestore = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    func listenToUserUpdates() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        listenerRegistration = firestore.collection("users")
            .document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("ユーザーフェッチエラー: \(error.localizedDescription)")
                    return
                }
                
                do {
                    self?.currentUser = try snapshot?.data(as: UserResponse.self)
                    print("ログインユーザー情報が更新されました(AppManager)")
                } catch {
                    print("ユーザーデータのデコードに失敗: \(error.localizedDescription)")
                }
            }
    }
    
    func stopListening() {
        listenerRegistration?.remove() // リスナーを解除
        currentUser = nil // ユーザー情報をクリア
    }
}
