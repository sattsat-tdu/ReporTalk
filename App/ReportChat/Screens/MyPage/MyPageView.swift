//
//  MyPageView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import SwiftUI
import SwiftUIFontIcon

struct MyPageView: View {
    
    let user: UserResponse

    var body: some View {
        List {
            Section(header: Text("プロフィール").fontWeight(.semibold)) {
                NavigationLink(
                    destination: ProfileDetailView()
                        .environmentObject(ProfileViewModel(user: user)),
                    label: {
                        HStack {
                            Group {
                                if let iconUrl = user.photoURL {
                                    IconImageView(
                                        urlString: iconUrl,
                                        size: 64)
                                } else {
                                    Image(systemName: "person.circle")
                                        .resizable()
                                        .frame(width: 64, height: 64)
                                }
                            }
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(user.userName)
                                    .font(.headline)
                                
                                Text("@\(user.handle)")
                                    .font(.callout)
                            }
                        }
                    })
            }
            
            CustomNavCell(
                navItem: NavItem(
                    destination: AnyView(SettingsView(section: settingResource)),
                    icon: .settings,
                    title: "設定"))
            .padding(.vertical, 4)
            .frame(minHeight: 38)
            
            VStack {
                Text("AdMob...")
            }
            .frame(height: 80)
            
            Section(header: Text("その他").fontWeight(.semibold)) {
                
                SafariCell(
                    safariItem: SafariItem(
                        title: "お問い合わせ・要望",
                        icon: .question_answer,
                        url: "https://sattsat.blogspot.com/2021/05/sattsat-sattsat-sattsat-admobgoogle-inc.html?m=1"
                    ))
                .padding(.vertical, 4)
                .frame(minHeight: 38)
                
                SafariCell(
                    safariItem: SafariItem(
                        title: "コピーライト",
                        icon: .content_paste,
                        url: "https://sattsat.blogspot.com/2022/07/blog-post.html?m=1"
                    ))
                .padding(.vertical, 4)
                .frame(minHeight: 38)
                
                SafariCell(
                    safariItem: SafariItem(
                        title: "プライバシーポリシー",
                        icon: .verified_user,
                        url: "https://sattsat.blogspot.com/2021/05/sattsat-sattsat-sattsat-admobgoogle-inc.html?m=1"
                    ))
                .padding(.vertical, 4)
                .frame(minHeight: 38)
            }
        }
        .listRowSpacing(8)
        .navigationTitle("マイページ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MyPageView(user: UserResponse(
        id: "12345", 
        handle: "user1234",
        userName: "Preview User",
        email: "preview@example.com",
        friends: ["Friend 1", "Friend 2"],
        photoURL: nil,
        rooms: ["room1", "room2"]
    ))
}
