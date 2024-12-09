//
//  MessageResponse.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/19
//  
//

import Foundation
import FirebaseFirestore
import SwiftUI

struct MessageResponse: Decodable {
    @DocumentID var id: String?
    let text: String
    let senderId: String
    let timestamp: Date
    let reportag: String?
    
    func toReportag() -> Reportag? {
        guard let reportag = reportag else {
            return nil
        }
        return Reportag(rawValue: reportag)
    }
    
    //Firebaseのフィールド名と一致させる
    enum CodingKeys: String, CodingKey {
        case id
        case text = "content"
        case senderId
        case timestamp
        case reportag
    }
    
    // Firebaseに書き込むための辞書変換
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "content": text,
            "senderId": senderId,
            "timestamp": timestamp
        ]
        // reportagがnilでない場合のみ追加
        if let reportag = reportag {
            dict["reportag"] = reportag
        }
        
        return dict
    }
}

enum Reportag: String, Codable, CaseIterable {
    case goodNews = "good_news"
    case badNews = "bad_news"
    case regular = "regular"
    case dailyReport = "daily_report"
    case breaking = "breaking"
    case announcement = "announcement"
    case question = "question"
    case important = "important"
    case anger = "anger"
    case emptiness = "emptiness"
    case despair = "despair"
    
    var tagName: String {
        switch self {
        case .goodNews:
            return "朗報"
        case .badNews:
            return "悲報"
        case .regular:
            return "定期"
        case .dailyReport:
            return "日報"
        case .breaking:
            return "速報"
        case .announcement:
            return "告知"
        case .question:
            return "質問"
        case .important:
            return "重要"
        case .anger:
            return "怒気" //憤怒?
        case .emptiness:
            return "虚無"
        case .despair:
            return "絶望"
        }
    }
    
    var color: Color {
        switch self {
        case .goodNews:
            return .goodNews
        case .badNews:
            return .badNews
        case .regular:
            return .regular
        case .dailyReport:
            return .dailyReport
        case .breaking:
            return .breaking
        case .announcement:
            return .announcement
        case .question:
            return .question
        case .important:
            return .important
        case .anger:
            return .anger
        case .emptiness:
            return .emptiness
        case .despair:
            return .despair
        }
    }
    
    var emoji: ImageResource {
        switch self {
        case .goodNews:
            return .goodNewsEmoji
        case .badNews:
            return .badNewsEmoji
        case .regular:
            return .regularEmoji
        case .dailyReport:
            return .dailyReportEmoji
        case .breaking:
            return .breakingEmoji
        case .announcement:
            return .announcementEmoji
        case .question:
            return .questionEmoji
        case .important:
            return .importantEmoji
        case .anger:
            return .angerEmoji
        case .emptiness:
            return .emptinessEmoji
        case .despair:
            return .despairEmoji
        }
    }
}

