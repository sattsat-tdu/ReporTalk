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
import SwiftUI

enum NavigationDestination: Hashable {
    case roomView(RoomResponse)
}

class AppManager: ObservableObject {
    static let shared = AppManager()
    
    @Published var currentUser: UserResponse?
    @Published var navigationPath = NavigationPath()
    private let firestore = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    func listenToUserUpdates() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        listenerRegistration = firestore.collection("users")
            .document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("ユーザーフェッチエラー: \(error.localizedDescription)")
                        return
                    }
                    
                    do {
                        self?.currentUser = try snapshot?.data(as: UserResponse.self)
                    } catch {
                        print("ユーザーデータのデコードに失敗(AppManager): \(error.localizedDescription)")
                    }
                }
            }
    }
    
    func stopListening() {
        listenerRegistration?.remove()
        DispatchQueue.main.async {
            self.currentUser = nil // ユーザー情報をクリア
        }
    }
}
