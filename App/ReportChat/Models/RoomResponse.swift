//
//  RoomResponse.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import Foundation
import FirebaseFirestore

struct RoomResponse: Decodable, Hashable {
//    let id: String
    @DocumentID var id: String?
    let members: [String]
    let roomIcon: String?
    let roomName: String?
    let lastUpdated: Date
    var readUsers: [String: Date] // ユーザーIDと最終閲覧日時
    
    //Firebaseのフィールド名と一致させる
    enum CodingKeys: String, CodingKey {
        case id
        case members
        case roomIcon = "roomicon"
        case roomName = "roomname"
        case lastUpdated
        case readUsers
    }
    
    // Firebaseに書き込むための辞書変換
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "members": members,
            "lastUpdated": lastUpdated,
            "readUsers": readUsers
        ]
        
        if let roomIcon = self.roomIcon {
            dict["roomicon"] = roomIcon
        }
        
        if let roomName = self.roomName {
            dict["roomname"] = roomName
        }
        return dict
    }
}
