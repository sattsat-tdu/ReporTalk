//
//  TabView.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/08/31
//
//

import SwiftUI
import SwiftUIFontIcon

enum TabList: CaseIterable {
    case home
    case rooms
    case timeline
    case mypage
    
    var iconText: Text {
        switch self {
        case .home:
            return FontIcon.text(.materialIcon(code: .home), fontsize: 25)
        case .rooms:
            return FontIcon.text(.materialIcon(code: .chat), fontsize: 25)
        case .timeline:
            return FontIcon.text(.materialIcon(code: .group), fontsize: 25)
        case .mypage:
            return FontIcon.text(.materialIcon(code: .person), fontsize: 25)
        }
    }
    
    var title: String {
        switch self {
        case .home:
            return "ホーム"
        case .rooms:
            return "ルーム"
        case .timeline:
            return "タイムライン"
        case .mypage:
            return "マイページ"
        }
    }
    
}

struct TabView: View {
    
    @Binding var selectedTab: TabList
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                ForEach(TabList.allCases, id: \.self) { tab in
                    tabItem(tab)
                        .frame(maxWidth: .infinity) // 幅を均等に広げる
                        .tag(tab)
                    if tab != TabList.allCases.last {
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 5)
        }
        .background()
    }
    
    @ViewBuilder
    private func tabItem(_ tab: TabList) -> some View {
        Button(action: {
            selectedTab = tab
        }, label: {
            VStack {
                tab.iconText
                
                Text(tab.title)
                    .font(.caption2).bold()
            }
            .foregroundStyle(.primary.opacity(selectedTab == tab ? 1 : 0.3))
        })
        .buttonStyle(PlainButtonStyle()) // ボタンのスタイルをプレーンにする
    }
}

#Preview {
    TabView(selectedTab: .constant(.home))
}
