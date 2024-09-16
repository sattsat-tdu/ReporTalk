//
//  RoomResponse.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import Foundation

struct RoomResponse: Decodable {
    let id: String
    let members: [UserResponse]
    let roomIcon: String?
    let roomName: String?
}
