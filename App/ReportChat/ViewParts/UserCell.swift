//
//  UserCell].swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/13
//  
//

import SwiftUI
import SwiftUIFontIcon

struct UserCell: View {
    
    let user: UserResponse
    
    var body: some View {
        HStack(spacing: 16) {
            
            if let photoURL = user.photoURL {
                URLtoImage(urlString: photoURL)
                    .clipShape(Circle())
            } else {
                FontIcon.text(.materialIcon(code: .account_circle),fontsize: 48)
            }
            
            VStack(alignment: .leading) {
                Text(user.userName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("@\(user.handle)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    UserCell(user: UserResponse(
        id: "12345",
        handle: "user1234",
        userName: "Preview User",
        email: "preview@example.com",
        fcmTokens: [],
        statusMessage: "私はニンジンの妖精と呼ばれています。",
        friends: ["Friend 1", "Friend 2"],
        photoURL: nil,
        rooms: ["room1", "room2"]
    ))
}
