//
//  SectionCell.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/25
//  
//

import SwiftUI
import SwiftUIFontIcon

struct SectionCell: View {
    
    let section: SettingSection
    
    var body: some View {
        NavigationLink(
            destination: SettingsView(section: section),
            label: {
                HStack(spacing: 8) {
                    if let icon = section.icon {
                        FontIcon.text(
                            .materialIcon(code: icon),
                            fontsize: 28
                        )
                    }

                    Text(section.title)
                        .font(.headline)
                }
            }
        )
    }
}

#Preview {
    SectionCell(
        section: SettingSection(
            icon: .settings,
            title: "設定",
            items: [])
    )
}
