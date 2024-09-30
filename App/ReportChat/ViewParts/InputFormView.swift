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
            
            Group {
                if style == .password {
                    SecureField(style.placeholder, text: $text)
                        .textInputAutocapitalization(.none)
                } else {
                    TextField(style.placeholder, text: $text)
                        .textInputAutocapitalization(.never)
                }
            }
            .padding()
            .keyboardType(.alphabet)
            .frame(height: 45)
            .background(.fieldBack)
            .clipShape(.rect(cornerRadius: 8))
        }
    }
}

#Preview {
    InputFormView(style: .id, text: .constant(""))
}
