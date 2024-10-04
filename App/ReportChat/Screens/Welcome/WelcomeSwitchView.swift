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
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .register:
                RegisterView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
        .animation(.easeInOut, value: viewModel.welcomeRouter)
        .fullScreenCover(isPresented: $viewModel.welcomeSettingsFlg) {
            WelcomeSettingsView()
        }
    }
}

#Preview {
    WelcomeSwitchView()
        .environmentObject(WelcomeViewModel(router: Router()))
}
