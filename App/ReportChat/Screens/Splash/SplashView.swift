//
//  SplashView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import SwiftUI

struct SplashView: View {
    
    @ObservedObject var viewModel: SplashViewModel
    
    var body: some View {
        Text("REPORT CHAT")
            .font(.largeTitle.bold())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SplashView(viewModel: SplashViewModel(router: Router()))
}
