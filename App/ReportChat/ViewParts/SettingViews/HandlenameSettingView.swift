//
//  HandlenameSettingView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/11/26
//  
//

import SwiftUI

struct HandlenameSettingView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    HandlenameSettingView()
enum HandleState {
    case loading
    case success
    case error
    
    var icon: Text {
        switch self {
        case .loading:
            FontIcon.text(.materialIcon(code: .data_usage))
        case .success:
            FontIcon.text(.materialIcon(code: .check_circle))
        case .error:
            FontIcon.text(.materialIcon(code: .error))
        }
    }
    
    var color: Color {
        switch self {
        case .loading:
            return .secondary
        case .success:
            return .green
        case .error:
            return .red
        }
    }
}
}
