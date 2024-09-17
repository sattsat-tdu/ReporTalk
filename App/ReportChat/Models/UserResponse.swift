//
//  UserResponse.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import Foundation
import FirebaseFirestore

struct UserResponse: Decodable {
    @DocumentID var id: String?
    let userName: String
    let email: String
    let friends: [String]
    let photoURL: String?
    let rooms: [String]
    
    //Firebaseのフィールド名と一致させる
    enum CodingKeys: String, CodingKey {
        case id
        case userName = "displayName"
        case email
        case friends
        case photoURL
        case rooms
    }
}
