//
//  SwiftDataManager.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/11/14
//  
//

import SwiftData
import Foundation

final class SwiftDataManager {
    static let shared = SwiftDataManager()
    
    private let modelContext: ModelContext
    
    private init() {
        do {
            // 1. Model 定義の型情報で Schema を初期化
            let schema = Schema([ReporTagMessage.self])
            // 2. Schema で ModelConfiguration を初期化
            let modelConfiguration = ModelConfiguration(schema: schema)
            // 3. ModelConfiguration で ModelContainer で初期化
            let modelContainer = try ModelContainer(
                for: ReporTagMessage.self,
                configurations: modelConfiguration
            )
            // 4. ModelContainer で ModelContext で初期化
            self.modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("SwiftDataの初期化に失敗しました: \(error)")
        }
    }
    
    func insert(_ reporTagMessage: ReporTagMessage) {
        do {
            modelContext.insert(reporTagMessage)
            try modelContext.save() // 明示的な保存
        } catch {
            print("SwiftDataへのSaveに失敗しました: \(error)")
        }
    }
    
    func fetchData(userId: String) -> [ReporTagMessage] {
        do {
            let filteredItems = try modelContext.fetch(
                FetchDescriptor<ReporTagMessage>(
                predicate: #Predicate {
                    $0.userId == userId
                }
              )
            )
            return filteredItems
        } catch {
            print("SwiftDataの取得に失敗しました: \(error)")
            return []
        }
    }
    
    //Attention デバック用データを全て消します
    func deleteAllData() {
        do {
            let fetchDescriptor = FetchDescriptor<ReporTagMessage>()
            let items = try modelContext.fetch(fetchDescriptor)
            
            for item in items {
                modelContext.delete(item)
            }
            
            try modelContext.save() // 削除を保存
            print("全てのデータが削除されました。")
        } catch {
            print("全てのデータの削除に失敗しました: \(error)")
        }
    }
}
