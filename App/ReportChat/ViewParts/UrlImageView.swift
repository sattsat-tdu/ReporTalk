//
//  UrlImageView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/17
//  
//

final class RoadImageViewModel: ObservableObject {
    @Published var imageData: Data?
    
    func fetchImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        // URLSessionを使用して非同期でデータを取得
        URLSession.shared.dataTask(with: url) { data, response, error in
            // エラーハンドリング
            if let error = error {
                print("エラーが発生しました: \(error)")
                return
            }

            guard let data = data else {
                print("データが存在しませんでした")
                return
            }

            DispatchQueue.main.async {
                self.imageData = data
            }
        }.resume() // タスクを開始
    }
}

import SwiftUI
import SwiftUIFontIcon

struct UrlImageView: View {
    let urlImage: String
    @State private var imageData: Data?
    @ObservedObject var viewModel = RoadImageViewModel()

    var body: some View {
        Group {
            if let data = viewModel.imageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                FontIcon.text(.materialIcon(code: .person), fontsize: 48)
            }
        }
        .onAppear {
            viewModel.fetchImage(urlString: urlImage)
        }
    }
}

#Preview {
    UrlImageView(urlImage: "https://1.bp.blogspot.com/-_CVATibRMZQ/XQjt4fzUmjI/AAAAAAABTNY/nprVPKTfsHcihF4py1KrLfIqioNc_c41gCLcBGAs/s400/animal_chara_smartphone_penguin.png")
}
