//
//  CapsuleButton.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/09
//  
//

import SwiftUI

struct CapsuleButton: View {
    let text: String
    let destination: AnyView? // オプションの NavigationLink 用ビュー
    let onClicked: (() -> Void)?
    
    init(text: String, destination: AnyView? = nil, onClicked: (() -> Void)? = nil) {
        self.text = text
        self.destination = destination
        self.onClicked = onClicked
    }
    
    var body: some View {
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
    
    private var capsuleView: some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(.buttonText)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.buttonBack)
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        VStack {
            // NavigationLinkとして動作するCapsuleButton
            CapsuleButton(text: "ナビゲーションボタン", destination: AnyView(Text("Next View")))
            
            // 通常のボタンとして動作するCapsuleButton（クリックでアクション）
            CapsuleButton(text: "ボタン処理", onClicked: {
                print("Button clicked")
            })
        }
        .padding()
    }
}
