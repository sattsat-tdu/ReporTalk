//
//  ToastView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/27
//  
//

import SwiftUI
import SwiftUIFontIcon
import AudioToolbox

struct ToastView: View {
    
    @State private var offsetY: CGFloat = -150
    let generator = UINotificationFeedbackGenerator()
    let animationDuration: Double = 0.5  // アニメーションの持続時間
    let type: ShowType
    let message: String
    let onHided: () -> Void  // コールバック用のクロージャ
    
    var body: some View {
        VStack() {
            
            HStack(spacing: 8) {
                FontIcon.text(.materialIcon(code: type.iconCode), fontsize: 24)
                
                Text(message)
                    .font(.headline)
                    .lineLimit(2)
                    .minimumScaleFactor(0.1)
            }
            .foregroundStyle(type.color)
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .padding(.horizontal)
            .offset(y: offsetY)
            
            Spacer()
        }
        .onAppear {
            showToast()
            vibration()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                hideToast()
            }
        }
    }
    
    func showToast() {
        withAnimation(.spring()) {
            self.offsetY = 0
        }
    }
    
    func hideToast() {
        withAnimation(.spring(duration: animationDuration)) {
            self.offsetY = -150
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            onHided()
        }
    }
    
    func vibration() {
        switch self.type {
        case .success:
            self.generator.notificationOccurred(.success)
        case .error:
            self.generator.notificationOccurred(.error)
        case .info:
            self.generator.notificationOccurred(.warning)
        }
    }
}

#Preview {
    ToastView(
        type: .info,
        message: "メッセージ",
        onHided: {})
}
