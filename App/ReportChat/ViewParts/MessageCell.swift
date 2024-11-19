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
    @State private var limitedText = ""
    @State private var isLimit = false
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 8) {
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
                VStack(spacing: 0) {
                    Text(limitedText)
                        .font(.body)
                    
                    if isLimit {
                        Text("・・・")
                            .font(.body.bold())
                            .foregroundStyle(.secondary)
                        
                        NavigationLink(
                            destination: TextDetailView(
                                text: message.text,
                                reportag: reportag),
                            label: {
                                Text("全て読む")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(12)
                                    .background(.item)
                                    .clipShape(Capsule())
                            })
                    }
                }
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
        .onAppear {
            checkText()
        }
    }
    
    //文字数・行表示制限
    func checkText(maxCharacters: Int = 500, maxLines: Int = 30) {
        let lines = message.text.split(separator: "\n", omittingEmptySubsequences: false)
        
        // 最大行数まで取得
        let limitedLines = lines.prefix(maxLines)
        let truncatedByLines = limitedLines.joined(separator: "\n")
        
        if lines.count > maxLines || truncatedByLines.count > maxCharacters {
            self.limitedText = String(truncatedByLines.prefix(maxCharacters))
            self.isLimit = true
        } else {
            self.limitedText = truncatedByLines
            self.isLimit = false
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


struct TextDetailView: View {
    
    let text: String
    let reportag: Reportag?
    private let lines: [String]
    
    init(text: String, reportag: Reportag?) {
        self.text = text
        self.reportag = reportag
        self.lines = text.components(separatedBy: .newlines)
    }
    
    var body: some View {
        ScrollView {
            if let reportag {
                Text(reportag.tagName)
                    .font(.largeTitle.bold())
                    .foregroundStyle(reportag.color)
            }
            
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    Text(line)
                }
            }
        }
        .padding()
        .background(.mainBackground)
    }
}
