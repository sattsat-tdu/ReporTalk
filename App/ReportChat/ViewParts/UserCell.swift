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
        HStack {
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
                        FontIcon.text(.materialIcon(code: .account_circle),fontsize: 48)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 48, height: 48)
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
        friends: ["Friend 1", "Friend 2"],
        photoURL: nil,
        rooms: ["room1", "room2"]
    ))
}
