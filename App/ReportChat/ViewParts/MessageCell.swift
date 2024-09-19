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
    
    var body: some View {
        Text(message.text)
            .foregroundStyle(.white)
            .padding()
            .background(.blue)
            .clipShape(.rect(cornerRadius: 8))
    }
}

#Preview {
    MessageCell(message: 
                    MessageResponse(
                        text: "サンプルテキスト",
                        senderId: "id1",
                        timestamp: Date())
    )
}
