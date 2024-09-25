//
//  SafariCell.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/25
//  
//

import SwiftUI
import SwiftUIFontIcon

struct SafariCell: View {
    
    let safariItem: SafariItem
    @State private var isShowSafariView = false
    
    var body: some View {
        Button(action: {
            isShowSafariView.toggle()
        }, label: {
            HStack(spacing: 8) {
                if let icon = safariItem.icon {
                    FontIcon.text(
                        .materialIcon(code: icon),
                        fontsize: 28
                    )
                }

                Text(safariItem.title)
                    .font(.headline)
            }
        })
        .fullScreenCover(isPresented: $isShowSafariView,
                         content: {
            SafariWebView(url: URL(string: safariItem.url)!)
        })
    }
}

#Preview {
    SafariCell(
        safariItem: SafariItem(
            title: "タイトル",
            icon: .priority_high,
            url: "https://www.google.co.jp"
        )
    )
}
