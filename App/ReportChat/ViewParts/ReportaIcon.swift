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
        ZStack {
            Image(.iconSource)
                .resizable()
                .colorMultiply(tag.color)
            
            Image(tag.emoji)
                .resizable()
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    List {
        ForEach(Reportag.allCases, id: \.self) { tag in
            HStack {
                ReportaIcon(size: 48, tag: tag)
                Text(tag.tagName)
            }
        }
    }
}
