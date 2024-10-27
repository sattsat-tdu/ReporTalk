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
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var roomsViewModel = RoomsViewModel()
    @EnvironmentObject var appManager: AppManager
    
    var body: some View {
        NavigationStack(path: $appManager.navigationPath) {
            VStack(spacing: 0) {
                switch selectedTab {
                case .home:
                    HomeView()
                case .rooms:
                    RoomsView()
                        .environmentObject(roomsViewModel)
                case .timeline:
                    Color.clear
                case .mypage:
                    MyPageView()
                }
                CustomTabView(selectedTab: $selectedTab)
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .roomView(let room):
                    RoomView()
                        .resignKeyboardOnDragGesture()
                        .environmentObject(RoomViewModel(room: room))
                }
            }
        }
        .environmentObject(notificationManager)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppManager.shared)
}
