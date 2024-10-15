//
//  NotificationManager.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/10/15
//
//

import Foundation
import FirebaseFirestore

@MainActor
class NotificationViewModel: ObservableObject {
    @Published var notifications: [NotificationModel] = []
    
    private let db = Firestore.firestore()
    
    func fetchNotifications(for userId: String) {
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
                
                self.notifications = documents.compactMap { document in
                    try? document.data(as: NotificationModel.self)
                }
            }
    }
}
