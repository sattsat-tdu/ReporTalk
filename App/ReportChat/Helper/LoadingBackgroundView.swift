//
//  LoadingBackgroundView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/11/23
//  
//

import SwiftUI

struct LoadingBackgroundView: View {
    
    private var gradientColors = [
        Color(uiColor: UIColor.systemGray5),
        Color(uiColor: UIColor.systemGray6),
        Color(uiColor: UIColor.systemGray5)
    ]
    
    @State private var startPoint:UnitPoint = .init(x: -1.8, y: -1.2)
    @State private var endPoint:UnitPoint = .init(x: 0, y: -0.2)
    
    var body: some View {
        LinearGradient(colors: gradientColors,
                       startPoint: startPoint,
                       endPoint: endPoint
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1)
                .repeatForever(autoreverses: false)){
                    startPoint = .init(x: 1, y: 1)
                    endPoint = .init(x: 2.2, y: 2.2)
                }
        }
    }
}

#Preview {
    LoadingBackgroundView()
}
