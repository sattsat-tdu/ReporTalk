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
    @ObservedObject var viewModel = MyPageViewModel()

    var body: some View {
        List {
            VStack {
                Text("プロフィール...")
            }
            .frame(height: 100)
            
            CustomNavCell(
                navItem: NavItem(
                    destination: AnyView(SettingsView(section: settingResource)),
                    icon: .settings,
                    title: "設定"))
            .listRowSeparator(.hidden)
            .padding(.vertical, 4)
            .frame(minHeight: 38)
            
            SafariCell(
                safariItem: SafariItem(
                    title: "お問い合わせ・要望",
                    icon: .question_answer,
                    url: "https://sattsat.blogspot.com/2021/05/sattsat-sattsat-sattsat-admobgoogle-inc.html?m=1"
                ))
            .listRowSeparator(.hidden)
            .padding(.vertical, 4)
            .frame(minHeight: 38)
            
            VStack {
                Text("AdMob...")
            }
            .frame(height: 80)
            
            SafariCell(
                safariItem: SafariItem(
                    title: "コピーライト",
                    icon: .content_paste,
                    url: "https://sattsat.blogspot.com/2022/07/blog-post.html?m=1"
                ))
            .listRowSeparator(.hidden)
            .padding(.vertical, 4)
            .frame(minHeight: 38)
            
            SafariCell(
                safariItem: SafariItem(
                    title: "プライバシーポリシー",
                    icon: .verified_user,
                    url: "https://sattsat.blogspot.com/2021/05/sattsat-sattsat-sattsat-admobgoogle-inc.html?m=1"
                ))
            .listRowSeparator(.hidden)
            .padding(.vertical, 4)
            .frame(minHeight: 38)
            
        }
        .listRowSpacing(10)
        .scrollContentBackground(.hidden)
        .navigationTitle("マイページ")
        .navigationBarTitleDisplayMode(.inline)
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
