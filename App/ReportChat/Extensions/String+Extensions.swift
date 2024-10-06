//
//  String+Extensions.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/07
//  
//

import SwiftUI

extension String {
    func fetchImageData() async -> Data? {
        guard let url = URL(string: self) else {
            print("URLの変換に失敗しました: \(self)")
            return nil
        }

        do {
            // URLSessionを使って非同期でデータを取得
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // HTTPレスポンスのステータスコードを確認（200が正常）
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                return data
            } else {
                print("不正なレスポンスコード: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                return nil
            }
        } catch {
            print("非同期の画像取得でエラー: \(error)")
            return nil
        }
    }
}
