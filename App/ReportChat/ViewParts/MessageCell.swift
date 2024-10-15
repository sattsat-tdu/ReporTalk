//
//  MessageView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/19
//  
//

import SwiftUI

struct MessageCell: View {
    
    let message: MessageResponse
    let isCurrentUser: Bool
    private let cornerRadius:CGFloat = 8
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading) {
            Text(message.text)
                .foregroundStyle(.primary)
                .padding()
                .background(isCurrentUser ? .sendMessage : .receivedMessage)
                .clipShape(.rect(
                    topLeadingRadius: cornerRadius,
                    bottomLeadingRadius: isCurrentUser ? cornerRadius : 0,
                    bottomTrailingRadius: isCurrentUser ? 0 : cornerRadius,
                    topTrailingRadius: cornerRadius
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
                        text: "サンプルテキスト",
                        senderId: "id1",
                        timestamp: Date()),
                isCurrentUser: true
    )
}
