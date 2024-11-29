//
//  ReportaIcon.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/11/29
//  
//

import SwiftUI

struct ReportaIcon: View {
    
    let size: CGFloat
    let tag: Reportag
    
    init(size: CGFloat = 256, tag: Reportag) {
        self.size = size
        self.tag = tag
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    VStack {
        ReportaIcon(tag: .goodNews)
        ReportaIcon(size: 24, tag: .goodNews)
    }
}
