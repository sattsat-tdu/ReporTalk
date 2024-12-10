//
//  WelcomeSwitchView.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/10/01
//
//

import SwiftUI

enum WelcomeRouter {
    case welcome
    case login
    case register
}

struct WelcomeSwitchView: View {
    
    @EnvironmentObject var viewModel: WelcomeViewModel
    
    var body: some View {
        Group {
            switch viewModel.welcomeRouter {
            case .welcome:
                WelcomeView()
                    .transition(.opacity)
            case .login:
                LoginView()
                    .transition(.opacity)
            case .register:
                RegisterView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: viewModel.welcomeRouter)
    }
}

#Preview {
    WelcomeSwitchView()
        .environmentObject(WelcomeViewModel(router: Router()))
}
