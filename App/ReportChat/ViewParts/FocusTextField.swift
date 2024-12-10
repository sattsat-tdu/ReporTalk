//
//  FocusTextField.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/12/09
//  
//

import SwiftUI

struct FocusedTextField: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    var onSearch: (() -> Void)? = nil

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.keyboardType = .alphabet
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .fieldBackground
        textField.returnKeyType = .search
        textField.delegate = context.coordinator
        textField.becomeFirstResponder()
        
        // テキスト変更イベントを監視、これにより@Binding可能
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged), for: .editingChanged)
        
        // 左側にアイコンを追加
        let iconView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iconView.tintColor = .gray
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 24)) // アイコンと余白
        paddingView.addSubview(iconView)
        iconView.center = paddingView.center

        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        // 横に最大化、テキストをたくさん入れた時にレイアウト崩れを防ぐ
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    // Coordinator を使ってデリゲートメソッドを実装
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: FocusedTextField

        init(_ parent: FocusedTextField) {
            self.parent = parent
        }
        
        @objc func textChanged(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.onSearch?()
            textField.resignFirstResponder() // キーボードを閉じる
            return true
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    FocusedTextField(placeholder: "プレースホルダー", text: $text)
        .frame(height: 48)
}
