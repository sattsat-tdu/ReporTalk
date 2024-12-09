//
//  UserDetailsView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/15
//  
//

import SwiftUI
import SwiftUIFontIcon

struct UserDetailView: View {
    
    let user: UserResponse
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = UserDetailViewModel()
    private let iconSize: CGFloat = 150
    private let messageCornerRadius: CGFloat = 16
    @State private var editProfileFlg = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                headerView
                
                profileView
                
                buttonView
                
                detailView
            }
            .padding()
        }
        .background(.mainBackground)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
        .onAppear {
            Task {
                await viewModel.checkPartnerState(for: user)
            }
        }
        .fullScreenCover(isPresented: $editProfileFlg) {
            EditUserProfileView()
        }
    }
    
    private var headerView: some View {
        HStack {
            FontIcon.button(.materialIcon(code: .close), action: {
                dismiss()
            }, fontsize: 28)
            .padding(12)
            .background(.item)
            .clipShape(Circle())
            
            Text("プロフィール")
                .font(.headline)
                .frame(maxWidth: .infinity)
            
            FontIcon.button(.materialIcon(code: .more_horiz), action: {}, fontsize: 28)
            .foregroundStyle(.buttonBackground)
            .clipShape(Circle())
        }
    }
    
    private var profileView: some View {
        VStack {
            Group {
                if let photoURL = user.photoURL {
                    URLtoImage(
                        urlString: photoURL,
                        iconSize: iconSize
                    )
                    .clipShape(Circle())
                } else {
                    FontIcon.text(.materialIcon(code: .account_circle),fontsize: iconSize)
                }
            }
            .padding(.bottom)
            .overlay(alignment: .bottomTrailing) {
                VStack {
                    Text("\(user.friends.count)")
                        .font(.headline)
                    Text("友達")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.item)
                .clipShape(Circle())
            }
            
            Text("@\(user.handle)")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(user.userName)
                .font(.title.bold())
        }
    }
    
    private var buttonView: some View {
        HStack {
            if let partnerState = viewModel.partnerState {
                switch partnerState {
                case .selfProfile:
                    CapsuleButton(
                        icon: .person,
                        style: .contrast,
                        text: "プロフィールを編集",
                        onClicked: {
                            self.editProfileFlg.toggle()
                        }
                    )
                case .friend:
                    CapsuleButton(
                        icon: .error,
                        style: .denger,
                        text: "友達から削除",
                        onClicked: {
                            viewModel.removeFriend(to: user)
                        }
                    )
                case .pendingRequest:
                    CapsuleButton(
                        icon: .loop,
                        style: .disable,
                        text: "友達申請中"
                    )
                case .pendingReceivedRequest:
                    CapsuleButton(
                        icon: .check,
                        style: .normal,
                        text: "友達申請を承認する",
                        onClicked: {
                            viewModel.addFriend(to: user)
                        }
                    )
                case .stranger:
                    CapsuleButton(
                        icon: .add_box,
                        style: .contrast,
                        text: "友達申請する",
                        onClicked: {
                            viewModel.sendFriendRequest(to: user)
                        }
                    )
                }
                
                CapsuleButton(
                    icon: .message,
                    style: .contrast,
                    text: "メッセージ",
                    onClicked: {
                        viewModel.navigateToRoom(partner: user)
                    }
                )
                .hidden(partnerState == .selfProfile)
            } else {
                CapsuleButton(icon: .loop,
                              style: .disable,
                              text: "読み込み中..."
                )
            }
        }
        .padding()
        .itemStyle()
    }
    
    private var detailView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("プロフィール")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(user.statusMessage)
        }
        .padding()
        .itemStyle()
    }
}

#Preview {
    UserDetailView(user: UserResponse(
        id: "12345",
        handle: "user1234",
        userName: "Preview User",
        email: "preview@example.com",
        statusMessage: "こんにちは、私の投稿のほぼ10割が悲報です。",
        friends: ["Friend 1", "Friend 2"],
        photoURL: "https://picsum.photos/300/200",
        rooms: ["room1", "room2"]
    ))
}
