//
//  CapsuleButton.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/09
//  
//

import SwiftUI

struct CapsuleButton: View {
    
    enum ButtonType {
        case primary
        case denger
        case disable
        case contrast
        
        var buttonBackColor: Color {
            switch self {
            case .primary:
                return .buttonBack
            case .denger:
                return .red
            case .disable:
                return .secondary.opacity(0.5)
            case .contrast:
                return .buttonText
            }
        }
    }
    
    let style: ButtonType
    let text: String
    let destination: AnyView? // オプションの NavigationLink 用ビュー
    let onClicked: (() -> Void)?
    
    init(style: ButtonType, text: String, destination: AnyView? = nil, onClicked: (() -> Void)? = nil) {
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
        Text(text)
            .font(.headline)
            .foregroundStyle(style == .contrast ? .buttonBack : .buttonText)
            .padding()
            .frame(maxWidth: .infinity)
            .background(style.buttonBackColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(style == .contrast ? .rounded : .clear, lineWidth: 2)
            )
    }
}

#Preview {
    NavigationStack {
        VStack {
            // NavigationLinkとして動作するCapsuleButton
            CapsuleButton(style: .primary, text: "ナビゲーションボタン", destination: AnyView(Text("Next View")))
            
            // 通常のボタンとして動作するCapsuleButton（クリックでアクション）
            CapsuleButton(style: .denger, text: "ボタン処理", onClicked: {
                print("Button clicked")
            })
        }
        .padding()
    }
}
