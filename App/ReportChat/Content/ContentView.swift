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
    @StateObject var notificationManager = NotificationManager()
    @StateObject private var roomsViewModel = RoomsViewModel()
    @EnvironmentObject var appManager: AppManager
    
    var body: some View {
        NavigationStack {
            if let currentUser = appManager.currentUser {
                VStack(spacing: 0) {
                    switch selectedTab {
                    case .home:
                        HomeView(currentUser: currentUser)
                    case .rooms:
                        RoomsView(viewModel: roomsViewModel)
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
        .environmentObject(notificationManager)
    }
}
#Preview {
    ContentView()
        .environmentObject(AppManager.shared)
}
