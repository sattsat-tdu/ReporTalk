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
    @ObservedObject var viewModel = RoomsViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                if let rooms = viewModel.rooms {
                    ForEach(rooms, id: \.id) { room in
                        Text(room.roomName ?? "ルーム名なし")
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchRooms(roomIDs: user.rooms)
        }
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
