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
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading) {
            Text(message.text)
                .foregroundStyle(.white)
                .padding()
                .background(.blue)
                .clipShape(.rect(cornerRadius: 8))
            
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
                isCurrentUser: false
    )
}
