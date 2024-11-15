//
//  MessagesView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/19
//  
//

import SwiftUI
import SwiftUIFontIcon

struct RoomView: View {
    
    @EnvironmentObject var viewModel: RoomViewModel

    @State private var selectTagViewFlg = false
    @State private var dynamicHeight: CGFloat = 40
    @FocusState var focus:Bool
    private let maxHeight: CGFloat = 240
    private let iconSize: CGFloat = 40
    private let maxMessageWidth = UIScreen.main.bounds.width * 0.6
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        if let messages = viewModel.messages {
                            ForEach(messages, id: \.id) { message in
                                let isCurrentUser = viewModel.loginUserId == message.senderId
                                HStack(alignment: .top,spacing: 4) {
                                    Group {
                                        if let iconUrl = viewModel.iconUrlString {
                                            CachedImage(url: iconUrl) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                case .success(let image):
                                                    Rectangle().aspectRatio(1, contentMode: .fill)
                                                        .overlay {
                                                            image
                                                                .resizable()
                                                                .scaledToFill()
                                                        }
                                                        .clipped()
                                                case .failure(_):
                                                    FontIcon.text(.materialIcon(code: .account_circle),
                                                                  fontsize: iconSize)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                        } else {
                                            FontIcon.text(.materialIcon(code: .account_circle),
                                                          fontsize: iconSize)
                                        }
                                    }
                                    .clipShape(Circle())
                                    .frame(width: iconSize, height: iconSize)
                                    .hidden(isCurrentUser)
                                    
                                    MessageCell(
                                        message: message,
                                        isCurrentUser: isCurrentUser
                                    )
                                    .frame(maxWidth: maxMessageWidth,
                                           alignment: isCurrentUser ? .trailing : .leading
                                    )
                                }
                                .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
                                .id(message.id)
                            }
//                            .padding(.horizontal, 8)
                        }
                    }
                    .padding()
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
                Button(action: {
                    selectTagViewFlg.toggle()
                }, label: {
                    if let reporTag = viewModel.selectedReporTag {
                        HStack {
                            FontIcon.text(.materialIcon(code: .insert_emoticon))
                            
                            Text(reporTag.tagName)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.leading, 4)
                        }
                        .padding(8)
                        .background(reporTag.color.gradient)
                        .clipShape(.rect(cornerRadius: 8))
                    } else {
                        FontIcon.text(.materialIcon(code: .add), fontsize: 32)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                })
                .transition(.scale)
                
                AutoResizingTextEditor(
                    text: $viewModel.messageText,
                    textHeight: $dynamicHeight, 
                    maxHeight: maxHeight
                )
                .focused(self.$focus)
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
            .background(.mainBackground)
        }
        .sheet(isPresented: $selectTagViewFlg) {
            SelectTagView(flg: $selectTagViewFlg,
                          reportag: $viewModel.selectedReporTag)
                .presentationDetents([.fraction(0.4), .fraction(0.8)])
        }
        .onAppear(perform: viewModel.onMessageViewAppear)
        .onDisappear(perform: viewModel.onMessageViewDisappear)
        .navigationTitle(viewModel.roomName)
        .background(.roomBack)
    }
}

#Preview {
    RoomView()
        .environmentObject(
            RoomViewModel(room:
                            RoomResponse(
                                members: [],
                                roomIcon: "",
                                roomName: "",
                                lastUpdated: Date(),
                                readUsers: [:])
                         )
        )
}
