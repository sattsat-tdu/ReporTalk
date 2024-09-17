//
//  RoomsCell.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/17
//  
//

import SwiftUI

struct RoomCell: View {
    
    let room: RoomResponse
    
    var body: some View {
        HStack {
            
        }
    }
}

#Preview {
    RoomCell(
        room: RoomResponse(
        id: "12345",
        members: ["Friend 1", "Friend 2"],
        roomIcon: nil,
        roomName: "room サンプル"
    ))
}
