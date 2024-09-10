//
//  CapsuleButton.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/09
//  
//

import SwiftUI

struct CapsuleButton: View {
    let text: String
    let onClicked: () -> Void
    var body: some View {
        Button(action: {
            onClicked()
        }, label: {
            Text(text)
                .font(.headline)
                .foregroundStyle(.buttonText)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.buttonBack)
                .clipShape(Capsule())
        })
    }
}

#Preview {
    CapsuleButton(text: "ボタンテキスト", onClicked: {})
}
