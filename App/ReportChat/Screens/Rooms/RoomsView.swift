//
//  RoomsView.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/09/16
//
//

import SwiftUI
import SwiftUIFontIcon

struct RoomsView: View {
    @EnvironmentObject var viewModel: RoomsViewModel
    @State private var addFriendViewFlg = false
    
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
                        Button(action: {
                            addFriendViewFlg.toggle()
                        }, label: {
                            VStack {
                                FontIcon.text(.materialIcon(code: .group_add),
                                              fontsize: 96)
                                Text("友達を追加して\nあなたの感情を共有しよう")
                                    .font(.headline)
                            }
                        })
                        .padding(.top, 48)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .sheet(isPresented: $addFriendViewFlg) {
            AddFriendsView()
        }
    }
}

#Preview {
    RoomsView()
        .environmentObject(RoomsViewModel())
}
