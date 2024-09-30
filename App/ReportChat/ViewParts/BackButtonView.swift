//
//  BackButtonView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/01
//  
//

import SwiftUI
import SwiftUIFontIcon

struct BackButtonView: View {
    
    @Environment(\.dismiss) var dismiss
    let onClicked: (() -> Void)?
    
    init(onClicked: (() -> Void)? = nil) {
        self.onClicked = onClicked
    }
    
    var body: some View {
        Button(action: {
            if let onClicked = onClicked {
                onClicked()
            } else {
                dismiss()
            }
        }, label: {
            FontIcon.text(.materialIcon(code: .arrow_back), fontsize: 32)
                .foregroundStyle(.buttonText)
                .padding(8)
                .background(.buttonBack)
                .clipShape(Circle())
        })
    }
}

#Preview {
    BackButtonView(onClicked: {
        
    })
}
