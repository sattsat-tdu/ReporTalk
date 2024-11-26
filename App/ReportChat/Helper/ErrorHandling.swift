//
//  ErrorHandling.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/07
//  
//

import SwiftUI

struct AlertType: Equatable {
    let title: String
    let message: String
}

struct CustomAlertView: View {
    var title: String
    var message: String
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .foregroundStyle(.primary)
                .font(.title.bold())
            
            Text(message)
                .foregroundStyle(.primary)
            
            Button(action: {
                action?()
            }, label: {
                Text("閉じる")
                    .foregroundStyle(.primary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.buttonBackground)
                    .clipShape(Capsule())
                    .padding(.top)
            })
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            Color.tab
                .clipShape(.rect(cornerRadius: 8))
                .shadow(
                    color: .black.opacity(0.1),
                   radius: 10
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.rounded, lineWidth: 2)
                )

        )
        .padding()
        
    }
}

struct CustomAlertModifier: ViewModifier {
    @Binding var alertType: AlertType?
    let action: (() -> Void)?

    func body(content: Content) -> some View {
        ZStack {
            content

            if let alertType = alertType {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                CustomAlertView(
                    title: alertType.title,
                    message: alertType.message,
                    action: {
                        action?()
                        self.alertType = nil
                    }
                )
                .transition(.scale)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: alertType)
    }
}

extension View {
    func customAlert(_ alertType: Binding<AlertType?>, action: (() -> Void)? = nil) -> some View {
        self.modifier(CustomAlertModifier(alertType: alertType, action: action))
    }
}

#Preview {
    CustomAlertView(title: "タイトル",
                    message: "メッセージ")
}
