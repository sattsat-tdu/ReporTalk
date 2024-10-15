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
    private let iconSize: CGFloat = 80
    private let messageCornerRadius:CGFloat = 16
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                FontIcon.button(.materialIcon(code: .close), action: {
                    dismiss()
                }, fontsize: 24)
                .padding(10)
                .foregroundStyle(.buttonText)
                .background(.buttonBack)
                .clipShape(Circle())
                
                Text("プロフィール")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                
                FontIcon.button(.materialIcon(code: .more_horiz), action: {
                    dismiss()
                }, fontsize: 24)
                .padding(10)
                .foregroundStyle(.buttonText)
                .background(.buttonBack)
                .clipShape(Circle())
            }
            .padding(.top)
            
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
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text("プロフィール\n")
                        .font(.headline)
                    
                    Text("ああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああ")
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
            
            Spacer()
            
            CapsuleButton(icon: .message,
                          style: .primary,
                          text: "メッセージ",
                          onClicked: {
                
            }
            )
        }
        .padding()
        .background(.tab)
        //モーダルをカスタム設定
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
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
