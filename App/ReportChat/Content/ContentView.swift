//
//  ContentView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/08/29
//  
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedTab: TabList = .home
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let user = viewModel.currentUser {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .rooms:
                        if let viewModel = viewModel.roomsViewModel {
                            RoomsView(viewModel: viewModel)
                        }
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
}

#Preview {
    ContentView()
}
