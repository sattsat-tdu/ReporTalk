//
//  LoadingView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/27
//  
//

import SwiftUI

struct LoadingView: View {
    
    let message: String
    let scaleEffect: CGFloat = 2
    let size = UIScreen.main.bounds.width / 2.5
    
    var body: some View {
        ZStack {
            //ロード中は背景にあるボタンなどの反応させないようにするため
            Color.black.opacity(0.2) // 背景をclearに設定
                .edgesIgnoringSafeArea(.all) // Safe
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(scaleEffect)
                    .frame(width: scaleEffect * 20, height: scaleEffect * 20)
                Text(message)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
            }
            .frame(width: size)
            .frame(minHeight: size)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 20))
        }
    }
}

#Preview {
    LoadingView(message: "ロード中")
}
