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
        if let rooms = viewModel.rooms {
            List(rooms, id: \.id) { room in
                NavigationLink(
                    destination: MessagesView()
                        .resignKeyboardOnDragGesture()
                        .environmentObject(viewModel.cellViewModel(for: room)),
                    label: {
                        RoomCell(viewModel: viewModel.cellViewModel(for: room))
                    }
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowBackground(Color.clear)
            }
            .background(.tab)
            .scrollIndicators(.hidden)  // スクロールバーの非表示
            .listStyle(.plain)  // List特有の余白を削除
            .navigationTitle("ルーム")
            .navigationBarTitleDisplayMode(.inline)
        } else {
            LoadingView(message: "ルームを取得中")
        }
    }
}


#Preview {
    RoomsView(viewModel: RoomsViewModel())
}
