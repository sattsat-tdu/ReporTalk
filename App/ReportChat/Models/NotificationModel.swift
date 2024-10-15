//
//  NotificationModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/15
//  
//

import Foundation
import FirebaseFirestore

struct NotificationModel: Identifiable, Codable {
    @DocumentID var id: String?
    let receiverId: String
    let message: String
    let url: String
    let noticeType: String
    let timestamp: Date
}
