//
//  MessageView.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/09/19
//
//

import SwiftUI
import SwiftUIFontIcon

struct MessageCell: View {
    
    let message: MessageResponse
    var reportag: Reportag? {
        return message.toReportag()
    }
    let isCurrentUser: Bool
    private let cornerRadius:CGFloat = 8
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 0) {
            VStack(spacing: 0) {
                
                if let reportag {
                    
                    HStack {
                        FontIcon.text(.materialIcon(code: .insert_emoticon))
                        
                        Text(reportag.tagName)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .padding(8)
                }
                
                Text(message.text)
                    .font(.body)
                    .padding(12)
                    .frame(minWidth: reportag != nil ? 100 : .none)
                    .background(
                        Group {
                            if let reportag {
                                Color.back
                                    .overlay {
                                        reportag.color.opacity(0.4)
                                    }
                            } else {
                                isCurrentUser ?
                                Color.sendMessage : Color.receivedMessage
                            }
                        }
                    )
            }
            .background(reportag?.color)
            .clipShape(.rect(
                topLeadingRadius: isCurrentUser ? cornerRadius : 0,
                bottomLeadingRadius: cornerRadius,
                bottomTrailingRadius: cornerRadius,
                topTrailingRadius: isCurrentUser ? 0 : cornerRadius
            ))
            
            Text(message.timestamp.toString())
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(isCurrentUser ? .trailing : .leading, 4)
        }
    }
}

#Preview {
    MessageCell(message:
                    MessageResponse(
                        text: "あ",
                        senderId: "id1",
                        timestamp: Date(),
                        reportag: Reportag.badNews.rawValue),
                isCurrentUser: true
    )
}
