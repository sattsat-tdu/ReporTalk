//
//  HomeView.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/09/16
//
//

import SwiftUI
import Charts
import SwiftUIFontIcon

struct HomeView: View {
    
    @State private var myProfileFlg = false
    @State private var selectModalFlg = false
    @State private var searchUsersFlg = false
    @EnvironmentObject var appManager: AppManager
    @StateObject private var viewModel = HomeViewModel()
    
    private let currentUser: UserResponse
    //タグの3行表示に使用
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    @State private var moveUp = false // アニメーション用の状態変数
    
    init?() {
        guard let user = AppManager.shared.currentUser else {
            return nil
        }
        self.currentUser = user
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                Section(header: headerView) {
                    
                    reporTagChartBox

                    friendBox
                    
                    myAdBox
                }
            }
            .padding()
        }
        .ignoresSafeArea(edges: [.top])
        .background(.mainBackground)
//        .navigationTitle("ホーム")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $myProfileFlg) {
            UserDetailView(user: currentUser)
        }
        .sheet(isPresented: $searchUsersFlg) {
            AddFriendsView()
        }
        .sheet(isPresented: $selectModalFlg) {
            SelectModalView(showModal: $selectModalFlg)
                .presentationDetents([.fraction(0.4), .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    if let photoURL = currentUser.photoURL {
                        URLtoImage(urlString: photoURL)
                            .clipShape(Circle())
                    } else {
                        FontIcon.text(.materialIcon(code: .account_circle),fontsize: 48)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(currentUser.userName)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Text("さん。こんにちは、\n今日も感情豊かに過ごしましょう")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .onTapGesture {
                    myProfileFlg.toggle()
                }
                
                Spacer()
                
                NavigationLink(destination: NotificationView(),
                               label: {
                    FontIcon.text(.materialIcon(code: .notifications),
                                  fontsize: 28)
                })
                .padding(8)
                .background(.item)
                .clipShape(Circle())
                
                
                FontIcon.button(.materialIcon(code: .add),
                                action: {
                    selectModalFlg = true
                },fontsize: 28)
                .padding(8)
                .background(.item)
                .clipShape(Circle())
                
                
            }
            
            Divider()
                .padding(.top)
        }
        .padding(.top, 48)
        .padding(.horizontal)
        .background(.mainBackground)
        .padding(.horizontal, -16)
    }
    
    private var reporTagChartBox: some View {
        NavigationLink(destination: ReporTagChartView(),
                       label: {
            VStack(spacing: 24) {
                HStack(alignment: .top) {
                    Text("レポータグ分析")
                        .font(.headline)
                    Spacer()
                    Text("詳細を見る  〉")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if viewModel.hasData, !viewModel.tagCounts.isEmpty {
                    Chart(Reportag.allCases, id: \.self) { tag in
                        if let count = viewModel.tagCounts[tag], count > 0 {
                            
                            SectorMark(
                                angle: .value("件数", Double(count)),
                                innerRadius: .ratio(0.4),
                                angularInset: 1
                            )
                            .cornerRadius(4)
                            .foregroundStyle(tag.color)
                            .annotation(position: .overlay) {
                                Image(tag.emoji)
                                    .resizable()
                                    .frame(width: 32, height: 32)
                            }
                        }
                    }
                    .frame(width: 180, height: 180)
                } else {
                    VStack(spacing: 16) {
                        Text("データが不足しています！")
                            .font(.headline)
                        Text("レポータグを送りましょう")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(height: 100)
                }
                
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Reportag.allCases, id: \.self) { tag in
                        HStack {
                            Image(systemName: "square.fill")
                                .foregroundStyle(tag.color)
                            Text(tag.tagName)
                                .foregroundStyle(.primary)
                        }
                    }
                }
                
                Divider()
                
                HStack() {
                    VStack(spacing: 4) {
                        ReportaIcon(size: 48, tag: .goodNews)
                            .offset(y: moveUp ? -5 : 5)

                        
                        Ellipse()
                            .fill(.primary)
                            .frame(width: 32, height: 12)
                            .opacity(moveUp ? 0.1 : 0.3)
                            .blur(radius: 3)
                    }
                    .frame(width: 56, height: 56)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: moveUp
                    )
                    .onAppear {
                        moveUp.toggle() // アニメーションをトリガー
                    }
                    
                    Text("〈 ")
                    
                    Text("この世の中がいいお知らせで満たされればいいのにぃ！")
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .itemStyle()
        })
    }
    
    private var friendBox: some View {
        VStack(spacing: 16) {
            Button(action: {
                searchUsersFlg.toggle()
            }, label: {
                HStack(spacing: 8) {
                    FontIcon.text(.materialIcon(code: .search), fontsize: 32)
                        .bold()
                    
                    Text("友達を探す")
                        
                    
                    Spacer()
                    
                    Text("〉")
                }
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
                .padding(.vertical, 12)
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary, lineWidth: 1)
                )
            })
            
            HStack {
                NavigationLink(destination: RoomsListView(),
                               label: {
                    HStack(spacing: 8) {
                        FontIcon.text(.materialIcon(code: .chat_bubble_outline),
                                      fontsize: 20)
                        
                        Text("ルーム")
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(currentUser.rooms.count)  〉")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.secondary, lineWidth: 1)
                    )
                })
                
                NavigationLink(destination: FriendListView(),
                               label: {
                    HStack(spacing: 8) {
                        FontIcon.text(.materialIcon(code: .people_outline),
                                      fontsize: 20)
                        
                        Text("友達")
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("\(currentUser.friends.count)  〉")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.secondary, lineWidth: 1)
                    )
                })
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .itemStyle()
    }
    
    private var myAdBox: some View {
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
        .itemStyle()
    }
}

#Preview {
    HomeView()
        .environmentObject(AppManager.shared)
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
                .background(.mainBackground)
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
                    .background(.item)
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
                    .background(.item)
                    .clipShape(.rect(cornerRadius: 8))
                })
                .sheet(isPresented: $addRoomFlg) {
                    RoomsListView()
                }
            }
            
            Spacer()
        }
        .padding()
        .background(.mainBackground)
    }
}
