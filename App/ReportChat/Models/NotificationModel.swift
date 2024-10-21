//
//  NotificationModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/15
//  
//

import Foundation
import FirebaseFirestore
import SwiftUIFontIcon

struct NotificationModel: Identifiable, Codable {
    @DocumentID var id: String?
    let senderId: String
    let receiverId: String
    let message: String
    let url: String
    let noticeType: String
    let timestamp: Date
    let isRead: Bool
    
    var toNoticeType: NoticeType? {
        return NoticeType(rawValue: noticeType) // NoticeTypeに変換
    }
}

enum NoticeType: String, Codable {
    case message = "message"
    case friendRequest = "friend_request"
    case announcement = "announcement"
    case systemUpdate = "system_update"
    
    var icon: MaterialIconCode {
        switch self {
        case .message:
            return .message
        case .friendRequest:
            return .accessibility
        case .announcement:
            return .notifications
        case .systemUpdate:
            return .error
        }
    }
}
