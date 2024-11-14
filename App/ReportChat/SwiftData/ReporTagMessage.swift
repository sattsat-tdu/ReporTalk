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
    var mId: String
    var reportag: String
    var message: String
    var timestamp: Date
    var rId: String
    var roomName: String
    
    init(mId: String, reportag: String, message: String, timestamp: Date, rId: String, roomName: String) {
        self.mId = mId
        self.reportag = reportag
        self.message = message
        self.timestamp = timestamp
        self.rId = rId
        self.roomName = roomName
    }
}
