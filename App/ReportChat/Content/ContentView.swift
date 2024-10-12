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
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        NavigationStack {
            if let currentUser = viewModel.currentUser {
                VStack(spacing: 0) {
                    switch selectedTab {
                    case .home:
                        HomeView(currentUser: currentUser)
                    case .rooms:
                        if let viewModel = viewModel.roomsViewModel {
                            RoomsView(viewModel: viewModel)
                        }
                    case .timeline:
                        Color.clear
                    case .mypage:
                        MyPageView(user: currentUser)
                    }
                    CustomTabView(selectedTab: $selectedTab)
                }
            } else {
                SplashView()
            }
        }
    }
}
#Preview {
    ContentView(viewModel: ContentViewModel())
}
