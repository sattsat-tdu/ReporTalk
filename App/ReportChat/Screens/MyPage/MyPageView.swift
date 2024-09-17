//
//  MyPageView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import SwiftUI

struct MyPageView: View {
    
    let user: UserResponse
    @ObservedObject var viewModel = MyPageViewModel()
    
    var body: some View {
        VStack {
            Text("ログイン情報")
                .font(.headline)
            
            Text(user.userName)
                .font(.headline)
            
            Text(user.id ?? "nilID")
            
            Divider()
            
            ForEach(user.rooms, id: \.self) { room in
                Text(room)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MyPageView(user: UserResponse(
        id: "12345",
        userName: "Preview User",
        email: "preview@example.com",
        friends: ["Friend 1", "Friend 2"],
        photoURL: nil,
        rooms: ["room1", "room2"]
    ))
}
