//
//  UserResponse.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import Foundation
import FirebaseFirestore

struct UserResponse: Identifiable, Decodable {
    @DocumentID var id: String?
    let handle: String
    let userName: String
    let email: String
    let statusMessage: String
    let friends: [String]
    let photoURL: String?
    let rooms: [String]
    
    //Firebaseのフィールド名と一致させる
    enum CodingKeys: String, CodingKey {
        case id
        case handle
        case userName = "displayName"
        case email
        case statusMessage
        case friends
        case photoURL
        case rooms
    }
    
    // Firebaseに書き込むための辞書変換
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "handle": handle,
            "displayName": userName,
            "email": email,
            "statusMessage": statusMessage,
            "friends": friends,
            "rooms": rooms,
        ]
        
        // photoURLがnilでない場合のみ追加
        if let photoURL = photoURL {
            dict["photoURL"] = photoURL
        }
        return dict
    }
}
