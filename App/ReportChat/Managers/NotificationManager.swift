//
//  NotificationManager.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/10/15
//
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class NotificationManager: ObservableObject {
    @Published var notifications: [NotificationModel]? = nil
    
    private let db = Firestore.firestore()
    
    init() {
        self.fetchNotifications()
    }
    
    func fetchNotifications() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("notifications")
            .whereField("receiverId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("通知の取得に失敗しました: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    return
                }
                
                let fetchedNotifications = documents.compactMap { document in
                    try? document.data(as: NotificationModel.self)
                }
                
                if self.notifications != nil {
                    let newMessage = fetchedNotifications.first?.message
                    UIApplication.showToast(type: .info,message: newMessage ?? "メッセージを取得できません")
                }
                self.notifications = fetchedNotifications
            }
    }
}
