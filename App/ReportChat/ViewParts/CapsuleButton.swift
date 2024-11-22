//
//  CapsuleButton.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/09
//  
//

import SwiftUI
import SwiftUIFontIcon

struct CapsuleButton: View {
    
    enum ButtonType {
        case normal
        case denger
        case disable
        case accent
        case contrast
        
        var buttonBackColor: Color {
            switch self {
            case .normal:
                return .buttonBack
            case .denger:
                return .red
            case .disable:
                return .secondary.opacity(0.5)
            case .accent:
                return .appAccent
            case .contrast:
                return .clear
            }
        }
    }
    
    let icon: MaterialIconCode?
    let style: ButtonType
    let text: String
    let destination: AnyView? // オプションの NavigationLink 用ビュー
    let onClicked: (() -> Void)?
    
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
        HStack {
            if let icon = icon {
                FontIcon.text(.materialIcon(code: icon),fontsize: 24)
            }
            
            Text(text)
        }
        .font(.headline)
        .foregroundStyle(style == .contrast ? .buttonBack : .buttonText)
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(style.buttonBackColor)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(style == .contrast ?
                    .buttonBack :Color.clear,
                        lineWidth: 2)
        )
    }
}

#Preview {
    NavigationStack {
        VStack {
            // NavigationLinkとして動作するCapsuleButton
            CapsuleButton(style: .normal, 
                          text: "ナビゲーションボタン",
                          destination: AnyView(Text("Next View")))
            
            CapsuleButton(icon: .airline_seat_flat_angled,
                          style: .accent,
                          text: "アクセント",
                          destination: AnyView(Text("Next View")))
            
            CapsuleButton(icon: .message,
                          style: .disable,
                          text: "押せない",
                          destination: AnyView(Text("Next View")))
            
            CapsuleButton(icon: .message,
                          style: .contrast,
                          text: "コントラスト",
                          destination: AnyView(Text("Next View")))
            
            // 通常のボタンとして動作するCapsuleButton（クリックでアクション）
            CapsuleButton(style: .denger, 
                          text: "デンジャー",
                          onClicked: {
                print("Button clicked")
            })
        }
        .padding()
    }
}
