//
//  RoomsListView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/11/28
//  
//

import SwiftUI

struct RoomsListView: View {
    var body: some View {
        VStack {
            Text("グループ機能は今後追加予定です！")
                .font(.title2.bold())
            Text("今しばらくお待ちください")
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.mainBackground)
    }
}

#Preview {
    RoomsListView()
}
