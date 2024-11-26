//
//  ReporTagChartView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/11/14
//  
//

import SwiftUI
import Charts
import SwiftData
import SwiftUIFontIcon

struct ReporTagChartView: View {
    
    @State private var allData: [ReporTagMessage] = []
    @State private var filteredData: [ReporTagMessage] = []
    @State private var tagCounts: [Reportag: Int] = [:]
    @State private var hasData = false
    @State private var selectedData: Reportag?
    @State private var selectTagViewFlg = false
    
    var body: some View {
        VStack {
            if hasData, !tagCounts.isEmpty {
                Chart(Reportag.allCases, id: \.self) { tag in
                    if let count = tagCounts[tag] {
                        SectorMark(
                            angle: .value("件数", Double(count)),
                            innerRadius: .ratio(0.6),
                            outerRadius: selectedData == tag ? 160 : 150,
                            angularInset: 1
                        )
                        .cornerRadius(10)
                        .foregroundStyle(selectedData == tag || selectedData == nil ? tag.color : .secondary)
                        .annotation(position: .overlay) {
                            Text("\(tag.tagName)")
                                .font(.headline)
                                .foregroundStyle(.primary)
                        }
                    }
                }
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture { location in
                                let angle = proxy.angle(at: location)
                                selectData(at: angle)
                            }
                    }
                }
                .chartBackground { _ in
                    if let selectedData {
                        VStack {
                            Text(selectedData.tagName)
                                .font(.headline)
                                .foregroundStyle(selectedData.color)
                        }
                    } else {
                        VStack {
                            Image(systemName: "carrot")
                                .font(.largeTitle)
                            Text("アイテムを選択")
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 320)
                
                .overlay(alignment: .bottomTrailing) {
                    FontIcon.button(.materialIcon(code: .filter_list), action: {
                        selectTagViewFlg.toggle()
                    },fontsize: 32)
                    .foregroundStyle(.buttonText)
                    .padding(8)
                    .background(.buttonBackground)
                    .clipShape(Circle())
               }
                Spacer()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredData) { data in
                            MessageCell(message: MessageResponse(
                                text: data.message,
                                senderId: data.userId,
                                timestamp: data.timestamp,
                                reportag: data.reportag.rawValue),
                                        isCurrentUser: false)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Text("データが不足しています！")
                        .font(.headline)
                    Text("レポータグを送りましょう")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .onAppear(perform: loadData)
        .onChange(of: selectedData) {
            withAnimation(.easeInOut(duration: 0.2)) {
                if let selectedData {
                    filteredData = allData.filter { $0.reportag == selectedData }
                } else {
                    filteredData = allData
                }
            }
        }
        .navigationTitle("レポータグ分析")
        .sheet(isPresented: $selectTagViewFlg) {
            SelectTagView(flg: $selectTagViewFlg,
                          reportag: $selectedData)
                .presentationDetents([.fraction(0.4), .fraction(0.8)])
        }
    }
    
    //分析データを取得
    private func loadData() {
        guard let userId = AppManager.shared.currentUser?.id else {return}
        let data = SwiftDataManager.shared.fetchData(userId: userId)
        self.allData = data
        self.filteredData = data
        self.hasData = !data.isEmpty
        
        // タグごとに件数をカウント
        let counts = Dictionary(grouping: data, by: { $0.reportag })
            .mapValues { $0.count }
        
        // EnumのReportagと一致させてtagCountsに変換
        var tagCountDict: [Reportag: Int] = [:]
        for tag in Reportag.allCases {
            tagCountDict[tag] = counts[tag] ?? 0
        }
        // 0件のエントリを削除
        self.tagCounts = tagCountDict.filter { $0.value > 0 }
    }
    
    //グラフアイテム選択時の処理
    private func selectData(at angle: Angle) {
        let total = tagCounts.values.reduce(0, +)
        guard total > 0 else { return }
        
        // Reportag.allCases に基づき、tagCounts を同じ順序に並べる
        let sortedTagCounts = Reportag.allCases
            .filter { tagCounts[$0] ?? 0 > 0 }
            .map { ($0, tagCounts[$0] ?? 0) }

        var cumulativeAngle: Double = 0.0

        for (tag, count) in sortedTagCounts {
            let tagAngle = Double(count) / Double(total) * 360
            
            // タップした角度が該当範囲に収まっているか確認
            if angle.degrees < cumulativeAngle + tagAngle {
                withAnimation(.easeInOut(duration: 0.2)) {
                    selectedData = (selectedData == tag) ? nil : tag
                }
                return
            }
            cumulativeAngle += tagAngle
        }
    }
}

#Preview {
    ReporTagChartView()
}
