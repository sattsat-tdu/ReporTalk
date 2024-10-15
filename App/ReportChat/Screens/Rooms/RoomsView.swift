//
//  RoomsView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import SwiftUI

struct RoomsView: View {
    
    @ObservedObject var viewModel: RoomsViewModel
    
    var body: some View {
        List {
            if let rooms = viewModel.rooms {
                ForEach(rooms, id: \.id) { room in
                    NavigationLink(
                        destination: MessagesView()
                            .resignKeyboardOnDragGesture()
                            .environmentObject(viewModel.cellViewModel(for: room)),
                        label: {
                            RoomCell(viewModel: viewModel.cellViewModel(for: room))
                        }
                    )
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowBackground(Color.clear)
            } else {
                // ロード中の表示を加える
                ProgressView("ルームを取得中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(.tab)
        .scrollIndicators(.hidden)  // スクロールバーの非表示
        .listStyle(.plain)  // List特有の余白を削除
        .navigationTitle("ルーム")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    RoomsView(viewModel: RoomsViewModel(
        user: UserResponse(
        id: "12345",
        handle: "user1234",
        userName: "Preview User",
        email: "preview@example.com",
        friends: ["Friend 1", "Friend 2"],
        photoURL: nil,
        rooms: ["room1", "room2"]
    )))
}
