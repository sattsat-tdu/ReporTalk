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
    case dailyReport = "daily_report"
    case breaking = "breaking"
    case announcement = "announcement"
    case question = "question"
    case important = "important"
    case emptiness = "emptiness"
    
    var tagName: String {
        switch self {
        case .goodNews:
            return "朗報"
        case .badNews:
            return "悲報"
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
        case .emptiness:
            return "虚無"
        }
    }
    
    var color: Color {
        switch self {
        case .goodNews:
            return .goodNews
        case .badNews:
            return .badNews
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
        case .emptiness:
            return .emptiness
        }
    }
}

