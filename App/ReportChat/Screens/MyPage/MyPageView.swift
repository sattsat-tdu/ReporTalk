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
    
    @EnvironmentObject var appManager: AppManager
    @State private var showProfileFlg = false
    private let iconSize: CGFloat = 64
    
    var body: some View {
        List {
            Group {
                if let currentUser = appManager.currentUser {
                    Section(header: Text("プロフィール").fontWeight(.semibold)) {
                        Button(action: {
                            showProfileFlg.toggle()
                        }, label: {
                            HStack {
                                if let photoURL = currentUser.photoURL {
                                    URLtoImage(
                                        urlString: photoURL,
                                        iconSize: iconSize)
                                        .clipShape(Circle())
                                } else {
                                    FontIcon.text(.materialIcon(code: .account_circle),fontsize: iconSize)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(currentUser.userName)
                                        .font(.headline)
                                    
                                    Text("@\(currentUser.handle)")
                                        .foregroundStyle(.secondary)
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                }
                            }
                        })
                    }
                    
                    CustomNavCell(
                        navItem: NavItem(
                            destination: AnyView(SettingsView(section: settingResource)),
                            icon: .settings,
                            title: "設定"))
                    
                    CustomNavCell(navItem: NavItem(
                        destination: AnyView(ReportansBookView()),
                        icon: .book,
                        title: "レポータ図鑑"))
                    
                    Section(header: Text("その他").fontWeight(.semibold)) {
                        
                        SafariCell(
                            safariItem: SafariItem(
                                title: "お問い合わせ・要望",
                                icon: .question_answer,
                                url: "https://sattsat.blogspot.com/2021/05/sattsat-sattsat-sattsat-admobgoogle-inc.html?m=1"
                            ))
                        
                        SafariCell(
                            safariItem: SafariItem(
                                title: "コピーライト",
                                icon: .content_paste,
                                url: "https://sattsat.blogspot.com/2022/07/blog-post.html?m=1"
                            ))
                        
                        SafariCell(
                            safariItem: SafariItem(
                                title: "プライバシーポリシー",
                                icon: .verified_user,
                                url: "https://sattsat.blogspot.com/2021/05/sattsat-sattsat-sattsat-admobgoogle-inc.html?m=1"
                            ))
                    }
                    
                }
            }
            .padding(.vertical, 4)
            .frame(minHeight: 38)
            .listRowBackground(Color.item)
        }
        .scrollContentBackground(.hidden)
        .background(.mainBackground)
        .listRowSpacing(10)
        .navigationTitle("マイページ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MyPageView()
        .environmentObject(AppManager.shared)
}
