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
    
    let urlString: String
    let size: CGFloat
    @State private var imageData = Data()
    
    var body: some View {
        Group {
            if let uiImage = UIImage(data: imageData) {
                Rectangle().aspectRatio(1, contentMode: .fill)
                    .overlay {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    }
                    .clipped()
                    .frame(width: size, height: size)
            } else {
                Image(.ninjinIMG)
                    .resizable()
                    .frame(width: size, height: size)
            }
        }
        .onAppear(perform: urlStringToData)
    }
    
    private func urlStringToData() {
        Task {
            guard let imageData = await FirebaseManager.shared.fetchImage(urlString: urlString) else { return }
            
            self.imageData = imageData
        }
    }
}

#Preview {
    IconImageView(
        urlString: "https://fastly.picsum.photos/id/447/200/300.jpg?hmac=WubV-ZWbMgXijt9RLYedmkiaSer2IFiVD7xek928gC8",
        size: 48
    )
}
