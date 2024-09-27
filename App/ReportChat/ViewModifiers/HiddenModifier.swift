//
//  HiddenModifier.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/24
//  
//

import SwiftUI

extension View {
   func hidden(_ isHidden: Bool) -> some View {
      modifier(HiddenModifier(isHidden: isHidden))
   }
}

// カスタム modifier
struct HiddenModifier: ViewModifier {
   let isHidden: Bool
   func body(content: Content) -> some View {
      if !isHidden {
         content
      }
   }
}
