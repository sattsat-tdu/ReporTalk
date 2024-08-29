//
//  LoginView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/08/29
//  
//

import SwiftUI

struct LoginView: View {
    
    @State private var id = ""
    @State private var passward = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("ログイン")
                .font(.title).bold()
            
            InputFormView(style: .id, text: $id)
            
            InputFormView(style: .password, text: $passward)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray.opacity(0.1))
    }
}

#Preview {
    LoginView()
}
