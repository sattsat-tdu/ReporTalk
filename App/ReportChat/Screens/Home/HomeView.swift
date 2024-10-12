//
//  HomeView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import SwiftUI

struct HomeView: View {
    
    let currentUser: UserResponse
    
    var body: some View {
        VStack() {
            HStack {
                Text("こんにちは！\n\(currentUser.userName)さん！")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                if let photoURL = currentUser.photoURL {
                    CachedImage(url: photoURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                        case .failure(_):
                            Image(systemName: "person.circle")
                                .resizable()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle")
                        .resizable().frame(width: 48, height: 48)
                }
            }

        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.roomBack)
        .navigationTitle("ホーム")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HomeView(currentUser: UserResponse(
        id: "12345",
        handle: "user1234",
        userName: "Preview User",
        email: "preview@example.com",
        friends: ["Friend 1", "Friend 2"],
        photoURL: "https://picsum.photos/300/200",
        rooms: ["room1", "room2"]
    ))
}
