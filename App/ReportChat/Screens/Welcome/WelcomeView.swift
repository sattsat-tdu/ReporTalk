//
//  WelcomeView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/30
//  
//

import SwiftUI

struct WelcomeView: View {
    
    @EnvironmentObject var viewModel: WelcomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Spacer()
            
            Text("REPORTALK")
                .font(.largeTitle.bold())
            
            Text("その日の感情を友達に共有しよう")
                .font(.body)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            CapsuleButton(
                text: "ログイン",
                onClicked: {
                    viewModel.navigate(to: .login)
                }
            )
            
            CapsuleButton(
                text: "新規登録",
                onClicked: {
                    viewModel.navigate(to: .register)
                }
            )
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

#Preview {
    WelcomeView()
        .environmentObject(WelcomeViewModel(router: Router()))
}
