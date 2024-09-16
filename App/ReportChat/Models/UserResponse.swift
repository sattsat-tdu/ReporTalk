//
//  UserResponse.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import Foundation

struct UserResponse: Decodable {
    let id: String
    let userName: String
    let email: String
    let friends: [String]
    let photoURL: String?
    let rooms: [String]
    
    init(data: [String: Any]) {
        self.id = data["uid"] as? String ?? ""
        self.userName = data["displayName"] as? String ?? "nilName"
        self.email = data["email"] as? String ?? ""
        self.friends = data["friends"] as? [String] ?? []
        self.photoURL = data["photoURL"] as? String
        self.rooms = data["rooms"] as? [String] ?? []
    }
}
