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
        VStack {
            Spacer()
            
            TabView(selectedTab: $selectedTab)
        }
    }
}

#Preview {
    ContentView()
}
