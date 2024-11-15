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
            if !viewModel.roomsModel.isEmpty {
                List(viewModel.roomsModel, id: \.room.id) { roomViewModel in
                    NavigationLink(
                        destination: RoomView()
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
        .background(.mainBackground)
        .navigationTitle("ルーム")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    RoomsView()
        .environmentObject(RoomsViewModel())
}
