//
//  HomeView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import SwiftUI
import SwiftUIFontIcon

struct HomeView: View {
    
    let currentUser: UserResponse
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                HStack {
                    Text("こんにちは！\n\(currentUser.userName)さん！")
                        .font(.title.bold())
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
                
                HStack(spacing: 16) {
                    NavigationLink(destination: Text("友達リストView"),
                                   label: {
                        VStack {
                            FontIcon.text(.materialIcon(code: .people_outline),
                                          fontsize: 64)
                            .foregroundStyle(.secondary)
                            
                            Text("友達リスト 〉")
                                .font(.headline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background()
                        .clipShape(.rect(cornerRadius: 8))
                    })
                    
                    NavigationLink(destination: Text("ルームリストView"),
                                   label: {
                        VStack {
                            FontIcon.text(.materialIcon(code: .forum),
                                          fontsize: 64)
                            .foregroundStyle(.secondary)
                            
                            Text("ルームリスト 〉")
                                .font(.headline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background()
                        .clipShape(.rect(cornerRadius: 8))
                    })
                }
                
                VStack(alignment: .leading) {
                    Text("レポータグ分析View")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background()
                .clipShape(.rect(cornerRadius: 8))
                
                NavigationLink(destination: Text("友達追加View"),
                               label: {
                    HStack {
                        FontIcon.text(.materialIcon(code: .group_add),
                                      fontsize: 80)
                        .foregroundStyle(.secondary)
                        
                        VStack(alignment: .trailing, spacing: 8) {
                            Text("報告相手を増やそう")
                                .font(.title2.bold())
                            
                            Text("友達を追加する 〉")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background()
                    .clipShape(.rect(cornerRadius: 8))
                })
                
                //リンクへ飛ばす。
                Link(destination: URL(string: "https://apps.apple.com/jp/developer/daisuke-ishii/id1609332032")!) {
                    HStack {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("こちらもおすすめ 〉")
                                .font(.headline)
                            Text("sattsatのアプリを\nもっとみてみる。")
                                .font(.footnote)
                        }
                        Spacer()
                        Image("MyAppAdIMG")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.black)
                .frame(height: 80)
                .padding()
                .background()
                .clipShape(.rect(cornerRadius: 8))
            }
            .padding()
        }
        .background(.roomBack)
        .navigationTitle("ホーム")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                FontIcon.button(.materialIcon(code: .add_box),
                                action: {
                    
                },
                fontsize: 32)
            }
        }
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
