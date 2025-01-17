//
//  SettingTestView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/25
//  
//

import SwiftUI

struct SettingsView: View {
    let section: SettingSection
    
    var body: some View {
        List {
            ForEach(section.items.indices, id: \.self) { index in
                let item = section.items[index]
                switch item {
                case .section(let subSection):
                    SectionCell(section: subSection)
                case .navItem(let navItem):
                    CustomNavCell(navItem: navItem)
                case .buttonItem(let buttonItem):
                    ButtonCell(buttonItem: buttonItem)
                case .toggleItem(let toggleItem):
                    ToggleCell(toggleItem: toggleItem)
                case .safariItem(let safariItem):
                    SafariCell(safariItem: safariItem)
                case .pickerItem(let pickerItem):
                    PickerCell(pickerItem: pickerItem)
                }
            }
            .padding(.vertical, 4)
            .frame(minHeight: 38)
            .listRowBackground(Color.item)
        }
        .scrollContentBackground(.hidden)
        .background(.mainBackground)
        .listRowSpacing(10)
        .navigationTitle(section.title)
    }
}

#Preview {
    SettingsView(section: settingResource)
}
