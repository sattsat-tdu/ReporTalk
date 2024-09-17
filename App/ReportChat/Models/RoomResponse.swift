//
//  RoomResponse.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import Foundation
import FirebaseFirestore

struct RoomResponse: Decodable {
//    let id: String
    @DocumentID var id: String?
    let members: [String]
    let roomIcon: String?
    let roomName: String?
    
    //Firebaseのフィールド名と一致させる
    enum CodingKeys: String, CodingKey {
        case id
        case members
        case roomIcon = "roomicon"
        case roomName = "roomname"
    }
}
