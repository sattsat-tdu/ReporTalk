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
        
        VStack() {
            
            Image(.splash)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                VStack {
                    Text("レポートーク")
                        .font(.largeTitle.bold())
                    
                    Text("今日の感情を友達に共有しよう")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack {
                    CapsuleButton(
                        style: .normal,
                        text: "ログイン",
                        onClicked: {
                            viewModel.navigate(to: .login)
                        }
                    )
                    
                    CapsuleButton(
                        style: .contrast,
                        text: "新規登録",
                        onClicked: {
                            viewModel.navigate(to: .register)
                        }
                    )
                }
                
                Button(action: {
                    
                }, label: {
                    Text("プライバシーポリシー")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                })
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.top)
        .preferredColorScheme(.light)
    }
}

#Preview {
    WelcomeView()
        .environmentObject(WelcomeViewModel(router: Router()))
        .preferredColorScheme(.light)
}
