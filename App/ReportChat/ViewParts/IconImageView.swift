//
//  IconImageView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/18
//  
//

import SwiftUI
import SwiftUIFontIcon

struct IconImageView: View {
    
    let data: Data
    let size: CGFloat
    
    var body: some View {
        if let uiImage = UIImage(data: data) {
            Rectangle().aspectRatio(1, contentMode: .fill)
                .overlay {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                }
                .clipped()
                .frame(width: size, height: size)
        } else {
            // 画像がない場合のプレースホルダー
            FontIcon.text(.materialIcon(code: .person), fontsize: size)
                .background(.red)
                .clipShape(Circle())
        }
    }
}

#Preview {
    IconImageView(data: Data(), size: 48)
}
