//
//  ReportansBookView.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/12/02
//
//

import SwiftUI

struct ReportansBookView: View {
    
    @State private var columnCount = 3
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: columnCount)
    }
    
    var body: some View {
        ScrollView {
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Reportag.allCases, id: \.self){ tag in
                    NavigationLink(
                        destination: ReportaDetailView(reportag: tag),
                        label: {
                            VStack {
                                ReportaIcon(size: 80, tag: tag)
                                Text(tag.tagName)
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .itemStyle()
                        })
                }
            }
            .padding()
        }
        .background(.mainBackground)
        .navigationTitle("レポータ図鑑")
    }
}

#Preview {
    ReportansBookView()
}
