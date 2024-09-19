//
//  HomeView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        Text("ホームです。")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HomeView()
}
