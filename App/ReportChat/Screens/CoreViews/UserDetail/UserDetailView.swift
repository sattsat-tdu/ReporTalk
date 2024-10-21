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
    private let iconSize: CGFloat = 80
    private let messageCornerRadius: CGFloat = 16
    
    var body: some View {
        Group {
            if let partnerState = viewModel.partnerState {
                VStack(spacing: 24) {
                    headerView
                    profileView
                    messageView
                    Spacer()
                    actionButtons(partnerState)
                }
                .padding()
                .background(.tab)
            } else {
                LoadingView(message: "ロード中")
            }
        }
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
        .onAppear {
            Task {
                await viewModel.checkPartnerState(for: user)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            FontIcon.button(.materialIcon(code: .close), action: {
                dismiss()
            }, fontsize: 28)
            .foregroundStyle(.buttonBack)
            .clipShape(Circle())
            
            Text("プロフィール")
                .font(.headline)
                .frame(maxWidth: .infinity)
            
            FontIcon.button(.materialIcon(code: .more_horiz), action: {}, fontsize: 28)
            .foregroundStyle(.buttonBack)
            .clipShape(Circle())
        }
        .padding([.top, .horizontal])
    }
    
    private var profileView: some View {
        HStack(spacing: 8) {
            Group {
                if let photoURL = user.photoURL {
                    CachedImage(url: photoURL) { phase in
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
                            Image(systemName: "person.circle")
                                .resizable()
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                }
            }
            .frame(width: iconSize, height: iconSize)
            .clipShape(Circle())
            .shadow(radius: 4)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(user.userName)
                    .font(.title.bold())
                
                Text("@\(user.handle)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var messageView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Text("プロフィール\n")
                    .font(.headline)
                Text("詳細なプロフィール内容をここに表示")
                    .font(.body)
            }
            .foregroundStyle(.primary)
            .padding()
            .background(.sendMessage)
            .clipShape(.rect(
                topLeadingRadius: 0,
                bottomLeadingRadius: messageCornerRadius,
                bottomTrailingRadius: messageCornerRadius,
                topTrailingRadius: messageCornerRadius
            ))
            .padding(.top)
        }
    }
    
    private func actionButtons(_ partnerState: PartnerState) -> some View {
        HStack(spacing: 16) {
            RoundedRectButton(
                icon: .message,
                style: .primary,
                text: "メッセージ",
                onClicked: {
                    // メッセージ処理
                })
            .hidden(partnerState == .selfProfile)
            
            switch partnerState {
            case .selfProfile:
                CapsuleButton(
                    icon: .person,
                    style: .contrast,
                    text: "プロフィールを編集",
                    onClicked: {
                        print("プロフィール編集")
                    }
                )
            case .friend:
                RoundedRectButton(
                    icon: .error,
                    style: .denger,
                    text: "友達から削除",
                    onClicked: {
                        viewModel.removeFriend(to: user)
                    }
                )
            case .pendingRequest:
                RoundedRectButton(
                    icon: .note,
                    style: .disable,
                    text: "友達申請中"
                )
            case .pendingReceivedRequest:
                RoundedRectButton(
                    icon: .check,
                    style: .primary,
                    text: "友達申請を承認する",
                    onClicked: {
                        viewModel.addFriend(to: user)
                    }
                )
            case .stranger:
                RoundedRectButton(
                    icon: .add_box,
                    style: .primary,
                    text: "友達申請する",
                    onClicked: {
                        viewModel.sendFriendRequest(to: user)
                    }
                )
            }
        }
    }
}

#Preview {
    UserDetailView(user: UserResponse(
        id: "12345",
        handle: "user1234",
        userName: "Preview User",
        email: "preview@example.com",
        friends: ["Friend 1", "Friend 2"],
        photoURL: "https://picsum.photos/300/200",
        rooms: ["room1", "room2"]
    ))
}
