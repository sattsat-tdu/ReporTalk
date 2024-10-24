//
//  RoomsView.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/09/16
//
//

import SwiftUI

struct RoomsView: View {
    @EnvironmentObject var viewModel: RoomsViewModel
    
    var body: some View {
        Group {
            if let rooms = viewModel.rooms {
                // Listに入れる前にキャッシュされたRoomViewModelを取得しておく
                let cachedRoomViewModels = rooms.compactMap { viewModel.cacheRoomViewModel(for: $0) }

                List(cachedRoomViewModels, id: \.room.id) { roomViewModel in
                    NavigationLink(
                        destination: MessagesView()
                            .environmentObject(roomViewModel)
                            .resignKeyboardOnDragGesture(),
                        label: {
                            RoomCell(viewModel: roomViewModel)
                        }
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowBackground(Color.clear)
                }
                .scrollIndicators(.hidden)
                .listStyle(.plain)
            } else {
                LoadingView(message: "ルームを取得中")
            }
        }
        .background(.tab)
        .navigationTitle("ルーム")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    RoomsView()
        .environmentObject(RoomsViewModel())
}
