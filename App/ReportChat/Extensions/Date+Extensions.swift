//
//  Date+Extension.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/19
//  
//

import SwiftUI

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "M月d日 HH:mm"
        return dateFormatter.string(from: self)
    }
    
    func toLastUpdatedString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        
        let calendar = Calendar.current
        // 今日の日付だったら時間だけ表示
        if calendar.isDateInToday(self) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: self)
        }
        
        // 昨日だったら「昨日」と表示
        if calendar.isDateInYesterday(self) {
            return "昨日"
        }
        
        // それ以前だったら日付のみ表示
        dateFormatter.dateFormat = "M月d日"
        return dateFormatter.string(from: self)
    }
}
