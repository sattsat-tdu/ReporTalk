//
//  RoomsView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import SwiftUI

struct RoomsView: View {
    
    let user: UserResponse
    var body: some View {
        Text("ルームです")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    RoomsView(user: UserResponse(
        id: "12345",
        userName: "Preview User",
        email: "preview@example.com",
        friends: ["Friend 1", "Friend 2"],
        photoURL: nil,
        rooms: ["room1", "room2"]
    ))
}
