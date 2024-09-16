//
//  MyPageView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import SwiftUI

struct MyPageView: View {
    
    @ObservedObject var viewModel = MyPageViewModel()
    
    var body: some View {
        VStack {
            Text("ログイン情報")
                .font(.headline)
            
            if let currentUser = viewModel.currentUser {
                Text(currentUser.userName)
                    .font(.headline)
                
                Text(currentUser.id)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MyPageView()
}
