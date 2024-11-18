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
            if let roomsModel = viewModel.roomsModel {
                ScrollView(showsIndicators: false) {
                    SearchTextField(placeholder: "検索",
                                    text: $viewModel.searchText)
                    .keyboardType(.default)
                    
                    if !roomsModel.isEmpty {
                        LazyVStack(spacing: 0) {
                            ForEach(roomsModel, id: \.room.id) { roomViewModel in
                                NavigationLink(
                                    destination: RoomView()
                                        .environmentObject(roomViewModel)
                                        .resignKeyboardOnDragGesture(),
                                    label: {
                                        RoomCell(viewModel: roomViewModel)
                                    }
                                )
                                Rectangle()
                                    .frame(height: 2)
                                    .clipShape(Capsule())
                                    .foregroundStyle(.gray.opacity(0.2))
                            }
                        }
                    } else {
                        Text("レポートを送信しよう！")
                    }
                }
                .padding()
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
