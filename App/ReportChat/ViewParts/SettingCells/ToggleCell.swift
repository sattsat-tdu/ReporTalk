//
//  ToggleCell.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/09/25
//
//

import SwiftUI
import SwiftUIFontIcon

struct ToggleCell: View {
    
    private let UD = UDManager.shared
    let toggleItem: ToggleItem
    @State private var isOn: Bool  // @Stateでトグルの状態を管理
    
    init(toggleItem: ToggleItem) {
        self.toggleItem = toggleItem
        // UserDefaults から初期値を取得
        let savedValue = UD.get(forKey: toggleItem.key) as Bool?
        _isOn = State(initialValue: savedValue ?? false)
    }
    
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                if let icon = toggleItem.icon {
                    FontIcon.text(
                        .materialIcon(code: icon),
                        fontsize: 28
                    )
                }
                
                Text(toggleItem.title)
                    .font(.headline)
                
                Toggle("", isOn: $isOn)
                    .onChange(of: isOn) {
                        UDManager.shared.set(isOn, forKey: toggleItem.key)
                    }
            }
            
            if let description = toggleItem.description {
                Text(description)
                    .font(.callout)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    ToggleCell(
        toggleItem: ToggleItem(
            key: SettingKeys.appearanceMode,
            title: "トグルアイテム",
            icon: .settings_power,
            description: "サンプルテキストを表示するかどうかを判定します。")
    )
}
