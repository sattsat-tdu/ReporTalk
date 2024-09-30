//
//  LoginViewModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/01
//  
//

import Foundation
import UIKit

@MainActor
final class LoginViewModel: ObservableObject {
    
    @Published var id = ""
    @Published var password = ""
    @Published var errorMessage = ""
    private let router: Router

    init(router: Router) {
        self.router = router
    }
    
    func login() {
        Task {
            errorMessage = ""
            UIApplication.showLoading()
            let loginResult = await FirebaseManager.shared.login(id: id, password: password)
            UIApplication.hideLoading()
            switch loginResult {
            case .success(let response):
                print(response.user)
                router.selectedRoute = .tab
            case .failure(let loginError):
                errorMessage = FirebaseError.shared.getErrorMessage(loginError)
            }
        }
    }
}
