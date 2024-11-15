//
//  ReporTagMessage.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/11/14
//  
//

import Foundation
import SwiftData

@Model
final class ReporTagMessage {
    var userId: String
    var reportag: Reportag
    var message: String
    var timestamp: Date
    var rId: String
    var roomName: String
    var roomIcon: String
    
    init(userId: String, reportag: Reportag, message: String, timestamp: Date, rId: String, roomName: String, roomIcon: String) {
        self.userId = userId
        self.reportag = reportag
        self.message = message
        self.timestamp = timestamp
        self.rId = rId
        self.roomName = roomName
        self.roomIcon = roomIcon
    }
}
