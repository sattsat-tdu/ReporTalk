//
//  ContentView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/08/29
//  
//

import SwiftUI

@MainActor
class UserViewModel: ObservableObject {
    @Published var currentUser: UserResponse?
    
    init() {
        self.fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.currentUser else {
            print("エラーです。。。。")
            return
        }
        Task {
            let currentUserResponse = await FirebaseManager.shared.fetchUser(userId: uid)
            if let user = currentUserResponse {
                self.currentUser = user
            }
        }
    }
}

struct ContentView: View {
    
    @State private var selectedTab: TabList = .home
    @StateObject var viewModel = UserViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            if let user = viewModel.currentUser {
                switch selectedTab {
                case .home:
                    HomeView()
                case .rooms:
                    RoomsView(user: user)
                case .timeline:
                    EmptyView()
                case .mypage:
                    MyPageView(user: user)
                }
            } else {
                Text("ローディング中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            TabView(selectedTab: $selectedTab)
        }
    }
}

#Preview {
    ContentView()
}
