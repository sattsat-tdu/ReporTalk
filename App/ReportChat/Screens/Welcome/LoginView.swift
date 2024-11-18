//
//  LoginView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/08/29
//  
//

import SwiftUI

struct LoginView: View {

    @EnvironmentObject var viewModel: WelcomeViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                BackButtonView(onClicked: {
                    viewModel.navigate(to: .welcome)
                })
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer().frame(height: 112)
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    Text("ログイン")
                        .font(.title).bold()
                        .padding(.top)
                    
                    InputFormView(
                        secureType: .normal,
                        keyboardType: .alphabet,
                        title: "メールアドレス",
                        placeholder: "name@domain.com",
                        text: $viewModel.id)
                    
                    InputFormView(
                        secureType: .secure,
                        keyboardType: .alphabet,
                        title: "パスワード",
                        placeholder: "パスワードを入力...",
                        text: $viewModel.password)
                    
                    Spacer()
                    
                    CapsuleButton(
                        style: viewModel.id.isEmpty || viewModel.password.isEmpty ? .disable : .normal,
                        text: "ログイン",
                        onClicked: {
                            viewModel.login()
                    })
                    
                    HStack {
                        Capsule().frame(height: 1)
                        Text("または...")
                            .lineLimit(1)
                            .font(.caption)
                        Capsule().frame(height: 1)
                    }
                    .foregroundStyle(.secondary)
                    
                    CapsuleButton(
                        style: .normal, 
                        text: "新規登録",
                        onClicked: {
                            viewModel.navigate(to: .register)
                        }
                    )
                }
                .padding()
                .padding(.bottom,24)
                .background(.mainBackground)
                .clipShape(.rect(cornerRadius: 32))
                .ignoresSafeArea(.all, edges: .bottom)
            }
            
        }
        .navigationTitle("ログイン")
    }
}

#Preview {
    LoginView()
        .environmentObject(WelcomeViewModel(router: Router()))
}
