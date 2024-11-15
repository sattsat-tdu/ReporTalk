//
//  HomeViewModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/12
//  
//

import SwiftUI
import SwiftData

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var tagCounts: [Reportag: Int] = [:]  // タグごとの件数
    @Published var hasData = false
    
    init() {
        fetchReporTagCounts()
    }
    func fetchReporTagCounts() {
        
        guard let userId = AppManager.shared.currentUser?.id else { return }
        
        let messages = SwiftDataManager.shared.fetchData(userId: userId)
        
        self.hasData = !messages.isEmpty
        
        // タグごとにメッセージの件数をカウント
        let counts = Dictionary(grouping: messages, by: { $0.reportag }).mapValues { $0.count }
        
        // EnumのReportagと一致させてtagCountsに変換
        var tagCountDict: [Reportag: Int] = [:]
        for tag in Reportag.allCases {
            tagCountDict[tag] = counts[tag] ?? 0  // データがないタグは0
        }

        self.tagCounts = tagCountDict
    }
}
