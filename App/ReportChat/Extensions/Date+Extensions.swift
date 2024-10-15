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
}
