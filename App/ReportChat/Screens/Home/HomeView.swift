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
    @State private var myProfileFlg = false
    @State private var selectModalFlg = false
    private let itemColor: Color = .tab
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                HStack {
                    Text("こんにちは！\n\(currentUser.userName)さん！")
                        .font(.title.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    Group {
                        if let photoURL = currentUser.photoURL {
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
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .onTapGesture {
                        myProfileFlg.toggle()
                    }
                }
                
                HStack(spacing: 16) {
                    NavigationLink(destination: FriendListView(),
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
                        .background(itemColor)
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
                        .background(itemColor)
                        .clipShape(.rect(cornerRadius: 8))
                    })
                }
                
                VStack(alignment: .leading) {
                    Text("レポータグ分析View")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(itemColor)
                .clipShape(.rect(cornerRadius: 8))
                
                NavigationLink(destination: AddFriendsView(),
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
                    .background(itemColor)
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
                    }
                }
                .frame(height: 80)
                .padding()
                .background(itemColor)
                .clipShape(.rect(cornerRadius: 8))
                
                NavigationLink(destination: NotificationView(),
                               label: {
                    Text("通知を確認")
                })
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
                    selectModalFlg = true
                },
                                fontsize: 32)
            }
        }
        .sheet(isPresented: $myProfileFlg) {
            UserDetailView(user: currentUser)
        }
        .sheet(isPresented: $selectModalFlg) {
            SelectModalView(showModal: $selectModalFlg)
                .presentationDetents([.fraction(0.4), .large])
                .presentationDragIndicator(.visible)
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

struct SelectModalView: View {
    @Binding var showModal: Bool
    @State private var addRoomFlg = false
    @State private var addFriendFlg = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("追加する内容を選んでください。")
                    .font(.title2.bold())
                
                Spacer()
                
                FontIcon.button(.materialIcon(code: .close), action: {
                    showModal.toggle()
                }
                ,fontsize: 24)
                .padding(10)
                .background(.tab)
                .clipShape(Circle())
            }
            .padding(.top)
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    addFriendFlg.toggle()
                }, label: {
                    VStack {
                        FontIcon.text(.materialIcon(code: .group_add),
                                      fontsize: 56)
                        .foregroundStyle(.secondary)
                        
                        Text("友達")
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .background(.tab)
                    .clipShape(.rect(cornerRadius: 8))
                })
                .sheet(isPresented: $addFriendFlg) {
                    AddFriendsView()
                }
                
                Button(action: {
                    addRoomFlg.toggle()
                }, label: {
                    VStack {
                        FontIcon.text(.materialIcon(code: .library_add),
                                      fontsize: 56)
                        .foregroundStyle(.secondary)
                        
                        Text("ルーム")
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .background(.tab)
                    .clipShape(.rect(cornerRadius: 8))
                })
                .sheet(isPresented: $addRoomFlg) {
                    Text("ルーム追加View")
                }
            }
            
            Spacer()
        }
        .padding()
        .background(.roomBack)
    }
}
