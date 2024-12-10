//
//  InputFormView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/08/29
//  
//

import SwiftUI

enum SecureType {
    case normal
    case secure
}

struct InputFormView: View {
    
    var secureType: SecureType = .normal
    let keyboardType: UIKeyboardType
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading) {

            Text(self.title)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Group {
                if secureType == .secure {
                    SecureField(self.placeholder, text: $text)
                        .textInputAutocapitalization(.none)
                } else {
                    TextField(self.placeholder, text: $text)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                }
            }
            .padding()
            .keyboardType(keyboardType)
            .frame(height: 45)
            .background(.fieldBackground)
            .clipShape(.rect(cornerRadius: 8))
        }
    }
}

#Preview {
    VStack {
        InputFormView(
            keyboardType: .alphabet,
            title: "メールアドレス",
            placeholder: "name@domain.com",
            text: .constant(""))
        
        InputFormView(
            secureType: .secure,
            keyboardType: .alphabet,
            title: "パスワード",
            placeholder: "パスワードを入力...",
            text: .constant(""))
    }
}
