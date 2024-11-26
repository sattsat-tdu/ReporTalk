//
//  TimelineView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/11/27
//  
//

import SwiftUI

struct TimelineView: View {
    var body: some View {
        VStack(spacing: 24) {
            
            Text("近日公開予定")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            Text("レポータグをSNSで共有しよう！")
                .font(.title2.bold())
        }
        .padding(.bottom, 24)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.mainBackground)
        .navigationTitle("タイムライン")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    TimelineView()
}
