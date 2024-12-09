//
//  URLtoImage.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/12/09
//  
//

import SwiftUI
import Kingfisher

struct URLtoImage: View {
    
    let urlString: String
    let iconSize: CGFloat
    
    init(urlString: String, iconSize: CGFloat = 48) {
        self.urlString = urlString
        self.iconSize = iconSize
    }
    
    var body: some View {
        Color.clear
            .frame(width: iconSize, height: iconSize)
            .aspectRatio(contentMode: .fill)
            .overlay(
                KFImage(URL(string: urlString))
                    .placeholder {
                        LoadingBackgroundView()
                    }
                    .resizable()
                    .scaledToFill()
            )
            .clipped()
    }
}

#Preview {
    URLtoImage(urlString: "https://picsum.photos/200/300")
}
