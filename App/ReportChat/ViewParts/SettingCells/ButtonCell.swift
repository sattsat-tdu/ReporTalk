//
//  ButtonCell.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/11/19
//
//

import SwiftUI
import SwiftUIFontIcon

struct ButtonCell: View {
    
    let buttonItem: ButtonItem
    
    var body: some View {
        Button(action: {
            buttonItem.onClicked()
        }, label: {
            VStack {
                HStack(spacing: 8) {
                    if let icon = buttonItem.icon {
                        FontIcon.text(
                            .materialIcon(code: icon),
                            fontsize: 28
                        )
                    }
                    Text(buttonItem.title)
                        .font(.headline)
                        .foregroundStyle(buttonItem.color)
                }
                
                if let description = buttonItem.description {
                    Text(description)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        })
    }
}

#Preview {
    ButtonCell(buttonItem: ButtonItem(
        icon: .accessible,
        color: .red,
        title: "ボタンタイトル",
        description: "詳しい説明です。",
        onClicked: {
            print("押されました")
        })
    )
}
