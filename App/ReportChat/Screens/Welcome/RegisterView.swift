//
//  RegisterView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/30
//  
//

import SwiftUI

struct RegisterView: View {
    
    @EnvironmentObject var viewModel: WelcomeViewModel
    @FocusState var isFocus: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            VStack {
                inputBox
                
                Spacer()
                
                buttonBox
            }
            .padding()
            .padding(.bottom, 24)
            .background(.item)
            .clipShape(.rect(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.1), radius: 3)
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .background(.mainBackground)
        .preferredColorScheme(.light)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onTapGesture {
            isFocus = false
        }
    }
    
    private var headerView: some View {
        ZStack {
            Image(.header)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
            
            Text("はじめまして！")
                .font(.title2)
                .fontWeight(.semibold)
        }
        .overlay(alignment: .topLeading) {
            BackButtonView(onClicked: {
                viewModel.navigate(to: .welcome)
            })
            .padding([.top,.leading], 8)
        }
    }
    
    private var inputBox: some View {
        VStack(alignment: .center, spacing: 24) {
            Text("新規登録")
                .font(.title2).bold()
            
            InputFormView(
                secureType: .normal,
                keyboardType: .alphabet,
                title: "メールアドレス",
                placeholder: "name@domain.com",
                text: $viewModel.id)
            .focused($isFocus)
            
            InputFormView(
                secureType: .secure,
                keyboardType: .alphabet,
                title: "パスワード",
                placeholder: "パスワードを入力...",
                text: $viewModel.password)
            .focused($isFocus)
        }
    }
    
    private var buttonBox: some View {
        VStack(spacing: 16) {
            CapsuleButton(
                style: viewModel.id.isEmpty || viewModel.password.isEmpty ? .disable : .normal,
                text: "新規登録",
                onClicked: {
                    viewModel.register()
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
                text: "ログイン",
                onClicked: {
                    viewModel.navigate(to: .login)
                }
            )
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(WelcomeViewModel(router: Router()))
}
