//
//  ProfileDetailView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/26
//  
//

import SwiftUI
import SwiftUIFontIcon

struct ProfileDetailView: View {
    
    @EnvironmentObject var viewModel: ProfileViewModel
    
    var body: some View {
        List {
            Section(header: Text("プロフィール写真").fontWeight(.semibold)){
                NavigationLink(
                    destination: Text("画像変更View"),
                    label: {
                        HStack {
                            if let iconUrl = viewModel.user.photoURL {
                                IconImageView(
                                    urlString: iconUrl,
                                    size: 64)
                                .clipShape(Circle())
                            } else {
                                FontIcon.text(.materialIcon(code: .person), fontsize: 64)
                            }
                            
                            Spacer()
                            
                            Text("画像を変更する")
                        }
                    })
            }

            Section(header: Text("名前").fontWeight(.semibold)){
                TextField("名前を入力...", text: $viewModel.userName)
            }
            
            CustomNavCell(navItem: NavItem(
                destination: AnyView(Text("友達リストViewだよ")),
                icon: .group,
                title: "友達リスト"
            ))
            .padding(.vertical, 4)
            .frame(minHeight: 38)
            
            Section {
                
                CustomNavCell(navItem: NavItem(
                    destination: AnyView(Text("パスワード変更Viewだよ")),
                    icon: .vpn_key,
                    title: "パスワードを変更する"
                ))
                .padding(.vertical, 4)
                .frame(minHeight: 38)
                
                Button("ログアウト"){
                    UIApplication.showModal(
                        modalItem: ModalItem(
                            type: .error,
                            title: "ログアウトしますか",
                            description: "ログアウトしても、メッセージの内容やアカウント情報は残ります。",
                            alignment: .bottom,
                            isCancelable: true,
                            onTapped: {
                                viewModel.logout()
                            }
                        )
                    )
                }
                .foregroundStyle(.red)
                
                Button("アカウントを削除する"){
                    
                }
                .foregroundStyle(.red)
            }
            
        }
        .listRowSpacing(8)
        .navigationTitle("プロフィール")
    }
}

#Preview {
    ProfileDetailView()
}
