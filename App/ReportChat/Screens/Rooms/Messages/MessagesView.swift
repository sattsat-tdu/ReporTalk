//
//  MessagesView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/19
//  
//

import SwiftUI

struct MessagesView: View {
    
    @EnvironmentObject var viewModel: RoomViewModel
    let maxMessageWidth = UIScreen.main.bounds.width * 0.9
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        if let messages = viewModel.messages {
                            ForEach(messages, id: \.id) { message in
                                let isCurrentUser = viewModel.currentUser == message.senderId
                                MessageCell(
                                    message: message
                                )
                                .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
                                .id(message.id)
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                    .onAppear {
                        // 最後のメッセージにスクロール
                        if let lastMessage = viewModel.messages?.last {
                            proxy.scrollTo(lastMessage.id)
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.roomName)
    }
}

#Preview {
    MessagesView()
}

#Preview {
    MessagesView()
}
