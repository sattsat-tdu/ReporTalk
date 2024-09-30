//
//  OverlayModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/27
//  
//

import Foundation
import SwiftUI
import SwiftUIFontIcon

enum ShowType {
    case success
    case error
    case info
    
    var iconCode: MaterialIconCode {
        switch self {
        case .success:
            return .check_circle
        case .error:
            return .error
        case .info:
            return .info
        }
    }
    
    var color: Color {
        switch self {
        case .success:
            return .green
        case .error:
            return .red
        case .info:
            return .primary
        }
    }
}

struct ModalItem {
    let type: ShowType
    let title: String
    let description: String?
    let alignment: Alignment
    let isCancelable: Bool
    let onTapped: (() -> Void)?
    
    init(
        type: ShowType,
        title: String,
        description: String? = nil,
        alignment: Alignment,
        isCancelable: Bool,
        onTapped: (() -> Void)? = nil
    ){
        self.type = type
        self.title = title
        self.description = description
        self.alignment = alignment
        self.isCancelable = isCancelable
        self.onTapped = onTapped
    }
}
