//
//  FriendListView.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/10/15
//
//

import SwiftUI
import SwiftUIFontIcon

struct FriendListView: View {
    
    @State private var friendList: [UserResponse]?
    @State private var filteredFriendList: [UserResponse] = []
    @State private var searchText = ""
    @State private var isModal = false
    @FocusState var isFocused: Bool
    @State private var selectedUser: UserResponse? = nil
    @EnvironmentObject var appManager: AppManager
    
    var body: some View {
        VStack {
            SearchTextField(placeholder: "ユーザーIDを検索",
                            text: $searchText)
            .focused($isFocused)
            .keyboardType(.alphabet)
            
            if let friendList = friendList {
                if filteredFriendList.isEmpty {
                    VStack {
                        Text(friendList.isEmpty
                             ? "友達がいないようです..."
                             : "「\(searchText)」に一致する友達がいません"
                        )
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    List(filteredFriendList, id: \.id) { user in
                        Button(action: {
                            self.selectedUser = user
                        }, label: {
                            UserCell(user: user)
                        })
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                }
            } else {
                LoadingView(message: "友達を検索中...")
            }
        }
        .padding()
        .background(.tab)
        .onAppear(perform: onAppear)
        .navigationTitle("友達リスト")
        //検索時はモーダルを閉じないように
        .interactiveDismissDisabled(!searchText.isEmpty)
        .sheet(item: $selectedUser) { user in
            UserDetailView(user: user)
        }
        .onChange(of: searchText, { filterFriendList(searchText) })
    }
    
    //ログインユーザーが持つ友達リストを取得
    @MainActor
    private func onAppear() {
        var users: [UserResponse] = []
        guard let currentUser = appManager.currentUser else { return }
        Task {
            for userId in currentUser.friends {
                let friendResult = await FirebaseManager.shared.fetchUser(userId: userId)
                switch friendResult {
                case .success(let friend):
                    users.append(friend)
                case .failure(_):
                    print("友達のロードに失敗")
                }
            }
            self.filteredFriendList = users
            self.friendList = users
        }
    }
    
    private func filterFriendList(_ query: String) {
        guard let friendList = self.friendList else { return }
        if query.isEmpty {
            // 検索テキストが空の場合、全ての友達を表示
            filteredFriendList = friendList
        } else {
            // 検索テキストに基づいてフィルタリング
            filteredFriendList = friendList.filter { user in
                user.handle.localizedCaseInsensitiveContains(query)
            }
        }
    }
}

#Preview {
    FriendListView()
        .environmentObject(AppManager.shared)
}
