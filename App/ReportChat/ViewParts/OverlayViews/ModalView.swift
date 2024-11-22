//
//  ModelView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/27
//  
//

import SwiftUI
import SwiftUIFontIcon

struct ModalView: View {
    
    let modalItem: ModalItem
    @State private var offsetY: CGFloat = UIScreen.main.bounds.height
    @State private var opacity = 0.0
    let animationDuration: Double = 0.3
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .opacity(self.opacity)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    if modalItem.isCancelable {
                        self.hideModel()
                    }
                }
            
            VStack(spacing: 16) {

                FontIcon.text(.materialIcon(code: modalItem.type.iconCode), fontsize: 56)
                    .foregroundStyle(modalItem.type.color)
                
                Text(modalItem.title)
                    .font(.title.bold())
                
                if let description = modalItem.description {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
                VStack {
                    CapsuleButton(
                        style: .denger, text: "はい",
                                  onClicked: {
                        modalItem.onTapped?()
                        hideModel()
                    })
                    
                    CapsuleButton(style: .normal, text: "いいえ",
                                  onClicked: {
                        hideModel()
                    })
                    .hidden(!modalItem.isCancelable)
                }
                .padding(.top)

            }
            .padding(.vertical, 32)
            .padding(.horizontal)
            .background(.mainBackground)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .frame(maxWidth: .infinity, maxHeight: .infinity,
                   alignment: modalItem.alignment)
            .padding(.horizontal, 8)
            .offset(y: offsetY)
            .onAppear {
                withAnimation(.spring(duration: animationDuration)) {
                    opacity = 1.0
                    offsetY = 0
                }
            }
        }
    }
    func hideModel() {
        withAnimation(.spring(duration: animationDuration)) {
            opacity = 0.0
            offsetY = UIScreen.main.bounds.height
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            UIApplication.hideModel()
        }
    }
}

#Preview {
    ModalView(
        modalItem: ModalItem(
            type: .success,
            title: "タイトル",
            description: "ここに説明文が表示されます。",
            alignment: .center,
            isCancelable: true,
            onTapped: {})
    )
}
