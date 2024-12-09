//
//  ReportaDetailView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/12/02
//  
//

import SwiftUI

struct ReportaDetailView: View {
    
    let reportag: Reportag
    
    var body: some View {
        VStack {
            ReportaIcon(tag: reportag)
            
            VStack(alignment: .leading, spacing: 24) {
                Text(reportag.tagName)
                    .font(.title2.bold())
                
                Text("ああああああああああああああああああああああああああああああああ")
                
                
            }
            .padding()
            .frame(maxWidth: .infinity)
            .itemStyle()
            
            Spacer()
            
            Button(action: {
                //画像を保存する
                if let image = render(reportag),
                    let data = image.pngData(),
                    let png = UIImage(data: data) {
                    UIImageWriteToSavedPhotosAlbum(png, nil, nil, nil)
                }

            }, label: {
                Text("画像を保存（開発者用）")
            })
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.mainBackground)
        .navigationTitle(reportag.tagName)
    }
    
    @MainActor
    func render(_ reportag: Reportag) -> UIImage? {
        let renderer = ImageRenderer(content: ReportaIcon(tag: reportag))
        renderer.scale = 1.0    //256pxで保存（scaleそのまま）
        return renderer.uiImage
    }
}

#Preview {
    ReportaDetailView(reportag: .goodNews)
}
