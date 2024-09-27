//
//  CustomNavCell.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/24
//  
//

import SwiftUI
import SwiftUIFontIcon

struct CustomNavCell: View {
    
    let navItem: NavItem

    var body: some View {
        NavigationLink(
            destination: navItem.destination,
            label: {
                VStack {
                    HStack(spacing: 8) {
                        if let icon = navItem.icon {
                            FontIcon.text(
                                .materialIcon(code: icon),
                                fontsize: 28
                            )
                        }

                        Text(navItem.title)
                            .font(.headline)
                    }
                    
                    if let description = navItem.description {
                        Text(description)
                            .font(.callout)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        )
    }
}
#Preview {
    CustomNavCell(
        navItem: NavItem(
            destination: AnyView(EmptyView()),
            icon: .settings,
            title: "設定項目", 
            description: "これこれこう変更します。")
    )
}
