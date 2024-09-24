//
//  AutoResizingTextEditor.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/20
//  
//

import UIKit
import SwiftUI

struct AutoResizingTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var textHeight: CGFloat
    let maxHeight: CGFloat
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
//        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.clear
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: AutoResizingTextEditor
        
        init(_ parent: AutoResizingTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
            DispatchQueue.main.async {
                let height = textView.sizeThatFits(textView.frame.size).height
                self.parent.textHeight = min(height, self.parent.maxHeight)
//                self.parent.textHeight = textView.sizeThatFits(textView.frame.size).height
            }
        }
    }
}
