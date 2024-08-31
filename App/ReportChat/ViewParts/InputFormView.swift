//
//  InputFormView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/08/29
//  
//

import SwiftUI

enum Style {
    case id
    case password
    
    var title: String {
        switch self {
        case .id:
            return "メールアドレス"
        case .password:
            return "パスワード"
        }
    }
    
    var placeholder: String {
        switch self {
        case .id:
            return "name@domain.com"
        case .password:
            return "パスワードを入力"
        }
    }
}

struct InputFormView: View {
    
    let style: Style
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading) {

            Text(style.title)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            if style == .password {
                SecureField(style.placeholder, text: $text)
                    .padding()
                    .keyboardType(.alphabet)
                    .textInputAutocapitalization(.none)
                    .frame(height: 40)
                    .background()
                    .clipShape(.rect(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray.opacity(0.2), lineWidth: 2)
                    )
            } else {
                TextField(style.placeholder, text: $text)
                    .padding()
                    .keyboardType(.alphabet)
                    .textInputAutocapitalization(.never)
                    .frame(height: 40)
                    .background()
                    .clipShape(.rect(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray.opacity(0.2), lineWidth: 2)
                    )
            }
        }
    }
}

#Preview {
    InputFormView(style: .id, text: .constant(""))
}
