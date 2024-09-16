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
    
    var body: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case .home:
                HomeView()
            case .rooms:
                RoomsView()
            case .timeline:
                EmptyView()
            case .mypage:
                EmptyView()
            }
            TabView(selectedTab: $selectedTab)
        }
    }
}

#Preview {
    ContentView()
}
