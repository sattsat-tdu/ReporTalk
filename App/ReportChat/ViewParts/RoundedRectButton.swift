//
//  RoundedRectButton.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/16
//  
//

import SwiftUI
import SwiftUIFontIcon

struct RoundedRectButton: View {
    
    enum ButtonType {
        case primary
        case denger
        case disable
        case contrast
        
        var buttonBackColor: Color {
            switch self {
            case .primary:
                return .buttonBackground
            case .denger:
                return .red
            case .disable:
                return .secondary.opacity(0.5)
            case .contrast:
                return .buttonText
            }
        }
    }
    
    let icon: MaterialIconCode?
    let style: ButtonType
    let text: String
    let destination: AnyView? // オプションの NavigationLink 用ビュー
    let onClicked: (() -> Void)?
    private let cornerRadius: CGFloat = 8
    
    init(icon: MaterialIconCode? = nil, style: ButtonType, text: String, destination: AnyView? = nil, onClicked: (() -> Void)? = nil) {
        self.icon = icon
        self.style = style
        self.text = text
        self.destination = destination
        self.onClicked = onClicked
    }
    
    var body: some View {
        Group {
            if let destination = destination {
                NavigationLink(destination: destination) {
                    capsuleView
                }
            } else {
                Button(action: {
                    onClicked?()
                }, label: {
                    capsuleView
                })
            }
        }
        .disabled(style == .disable)
    }
    
    private var capsuleView: some View {
        VStack {
            if let icon = icon {
                FontIcon.text(.materialIcon(code: icon),fontsize: 32)
            }
            
            Text(text)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
        }
        .foregroundStyle(style == .contrast ? .buttonBackground : .buttonText)
        .padding()
        .frame(maxWidth: .infinity)
        .background(style.buttonBackColor)
        .clipShape(.rect(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(style == .contrast ? .rounded : .clear, lineWidth: 2)
        )
    }
}

#Preview {
    NavigationStack {
        HStack {
            // NavigationLinkとして動作するCapsuleButton
            RoundedRectButton(style: .primary,
                          text: "ナビゲーションボタン",
                          destination: AnyView(Text("Next View")))
            
            RoundedRectButton(icon: .message,
                          style: .primary,
                          text: "ナビゲーションボタン",
                          destination: AnyView(Text("Next View")))
            
            // 通常のボタンとして動作するCapsuleButton（クリックでアクション）
            RoundedRectButton(style: .denger,
                          text: "ボタン処理",
                          onClicked: {
                print("Button clicked")
            })
        }
        .padding()
    }
}
