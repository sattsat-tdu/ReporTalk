//
//  MessageResponse.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/19
//  
//

import Foundation
import FirebaseFirestore

struct MessageResponse: Decodable {
    @DocumentID var id: String?
    let text: String
    let senderId: String
    let timestamp: Date
    
    //Firebaseのフィールド名と一致させる
    enum CodingKeys: String, CodingKey {
        case id
        case text = "content"
        case senderId
        case timestamp
    }
    
    // Firebaseに書き込むための辞書変換
    func toDictionary() -> [String: Any] {
        return [
            "content": text,
            "senderId": senderId,
            "timestamp": Timestamp(date: timestamp)  // DateをTimestampに変換
        ]
    }
}
