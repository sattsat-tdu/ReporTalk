//
//  SearchTextField.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/14
//  
//

import SwiftUI
import SwiftUIFontIcon

struct SearchTextField: View {
    
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            FontIcon.text(.materialIcon(code: .search),fontsize: 24)
            
            TextField("ユーザーIDを検索...", text: $text)
        }
        .padding(10)
        .background(.fieldBack)
        .clipShape(.rect(cornerRadius: 8))
    }
}

#Preview {
    SearchTextField(placeholder: "テキストを検索", 
                    text: .constant(""))
}
