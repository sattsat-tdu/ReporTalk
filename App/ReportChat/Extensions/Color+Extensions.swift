//
//  Color+Extensions.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/11/29
//  
//

import SwiftUI

extension Color {
    /// `Color` から推奨されるテキストカラーを計算
    var recommendedTextColor: Color {
        UIColor(self).recommendedTextColor.toColor()
    }
}

extension UIColor {
    /// 明度に基づいて推奨されるテキストカラーを返す
    var recommendedTextColor: UIColor {
        let threshold: CGFloat = 0.5 // 基準値 高くするほど明るいカラーでも白テキストが使われやすい
        return brightness > threshold ? .black : .white
    }

    /// 明度を計算
    private var brightness: CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        // RGB 値を取得
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // 明度を計算
        return (red * 0.299 + green * 0.587 + blue * 0.114)
    }
}

extension UIColor {
    /// `UIColor` を `Color` に変換
    func toColor() -> Color {
        return Color(self)
    }
}

