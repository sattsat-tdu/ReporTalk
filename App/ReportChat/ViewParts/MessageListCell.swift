//
//  MessageListCell.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/12/06
//  
//

import SwiftUI

struct MessageListCell: View {
    
    let message: MessageResponse
    let reportag: Reportag
    
    init?(message: MessageResponse) {
        self.message = message
        guard let reportag = message.toReportag() else { return nil }
        self.reportag = reportag
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ReportaIcon(size: 48, tag: reportag)
            
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text(reportag.tagName)
                        .font(.headline)
                    Spacer()
                    Text(message.timestamp.toString())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text(message.text)
            }
        }
        .frame(height: 60)
    }
}

#Preview {
    MessageListCell(message: MessageResponse(
        text: "メッセージです",
        senderId: "user12345",
        timestamp: Date(),
        reportag: "good_news")
    )
}
