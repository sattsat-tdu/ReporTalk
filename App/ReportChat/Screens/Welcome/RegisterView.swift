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
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        Text("はじめまして！")
                            .font(.title).bold()
                            .padding(.top)
                        
                        Text("アイコン設定(任意)")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 16){
                            PhotoPickerView(selectedImageData: $viewModel.imageData)
                            
                            Text("アイコンタップで画像\((viewModel.imageData != nil) ? "変更" : "追加")")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        
                        InputFormView(
                            secureType: .normal,
                            title: "名前",
                            placeholder: "田中 太郎",
                            text: $viewModel.userName)
                        
                        InputFormView(
                            secureType: .normal,
                            title: "メールアドレス",
                            placeholder: "name@domain.com",
                            text: $viewModel.id)
                        
                        InputFormView(
                            secureType: .secure,
                            title: "パスワード",
                            placeholder: "パスワードを入力...",
                            text: $viewModel.password)
                        
                        Spacer()

                        CapsuleButton(
                            style: viewModel.id.isEmpty || viewModel.password.isEmpty
                            ? .disable : .primary,
                            text: "新規登録",
                            onClicked: {
                                viewModel.register()
                            })
                        .disabled(viewModel.userName.isEmpty || viewModel.id.isEmpty || viewModel.password.isEmpty)
                        
                        HStack {
                            Capsule().frame(height: 1)
                            Text("または...")
                                .lineLimit(1)
                                .font(.caption)
                            Capsule().frame(height: 1)
                        }
                        .foregroundStyle(.secondary)
                        
                        CapsuleButton(
                            style: .primary,
                            text: "ログイン",
                            onClicked: {
                                viewModel.navigate(to: .login)
                            }
                        )
                        
                        Spacer().frame(height: 50)
                    }
                }
                .padding()
                .background(.tab)
                .clipShape(.rect(cornerRadius: 32))
                .ignoresSafeArea(.all, edges: .bottom)
            }
            
        }
        .navigationTitle("新規登録")
    }
}

#Preview {
    RegisterView()
        .environmentObject(WelcomeViewModel(router: Router()))
}
