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
    let friends: [UserResponse]
    let photoURL: String?
    let rooms: [RoomResponse]
}
