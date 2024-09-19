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
    @StateObject var viewModel = RoomsViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                if let rooms = viewModel.rooms {
                    ForEach(rooms, id: \.id) { room in
                        let roomCellViewModel = viewModel.cellViewModel(for: room)
                        NavigationLink(
                            destination: EmptyView(),
                            label: {
                                RoomCell(viewModel: roomCellViewModel)
//                                    .background(.item)
                        })
                    }
                    .listRowInsets(EdgeInsets())  //List内の余白を削除
                    .listRowBackground(Color.clear)
                    .padding(.horizontal)
                }
            }
            .onAppear {
                viewModel.fetchRooms(roomIDs: user.rooms)
            }
            .scrollIndicators(.hidden)  //スクロールバーの削除
            .listStyle(.plain)  //List特有の余白を削除
            .navigationTitle("ルーム")
            .navigationBarTitleDisplayMode(.inline)
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
