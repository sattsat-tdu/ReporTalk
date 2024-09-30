//
//  LoginView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/08/29
//  
//

import SwiftUI

struct LoginView: View {
    
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Text("ログイン")
                .font(.title).bold()
            
            InputFormView(style: .id, text: $viewModel.id)
            
            InputFormView(style: .password, text: $viewModel.password)
            
            Text(viewModel.errorMessage)
                .foregroundStyle(.red)
                .padding(.vertical)
            
            CapsuleButton(text: "ログイン",
                          onClicked: {
                viewModel.login()
            })
            .disabled(viewModel.id.isEmpty || viewModel.password.isEmpty)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.back)
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel(router: Router()))
}
