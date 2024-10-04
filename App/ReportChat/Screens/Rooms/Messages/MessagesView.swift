//
//  MessagesView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/19
//  
//

import SwiftUI
import SwiftUIFontIcon

struct MessagesView: View {
    
    @EnvironmentObject var viewModel: RoomViewModel
    @State private var dynamicHeight: CGFloat = 40
    private let maxHeight: CGFloat = 240
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        if let messages = viewModel.messages {
                            ForEach(messages, id: \.id) { message in
                                let isCurrentUser = viewModel.currentUser == message.senderId
                                MessageCell(
                                    message: message, 
                                    isCurrentUser: isCurrentUser
                                )
                                .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
                                .id(message.id)
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                    .onAppear {
                        proxy.scrollTo("lastMessage", anchor: .bottom)
                    }
                    .onChange(of: viewModel.lastMessageId) {
                        if let id = viewModel.lastMessageId {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                proxy.scrollTo(id, anchor: .bottom)
                            }
                        }
                    }
                    Spacer().frame(height: 24)
                        .id("lastMessage")
                }
            }
            Divider()
            HStack(spacing: 8) {
                AutoResizingTextEditor(
                    text: $viewModel.messageText,
                    textHeight: $dynamicHeight, 
                    maxHeight: maxHeight
                )
                .frame(height: dynamicHeight, alignment: .top)
                .padding(.horizontal)
                .background(.gray.opacity(0.2))
                .clipShape(.rect(cornerRadius: 10))
                
                Button(action: {
                    viewModel.handleSend()
                    self.dynamicHeight = 40
                }, label: {
                    FontIcon.text(.materialIcon(code: .send), fontsize: 32)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                })
                .tint(.blue)
                .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .frame(height: min(dynamicHeight, maxHeight) + 16)
            .background(.tab)
        }
        .navigationTitle(viewModel.roomName)
        .background(.tab)
    }
}

#Preview {
    MessagesView()
        .environmentObject(
            RoomViewModel(room:
                            RoomResponse(
                                members: [],
                                roomIcon: "",
                                roomName: "")
                         )
        )
}
