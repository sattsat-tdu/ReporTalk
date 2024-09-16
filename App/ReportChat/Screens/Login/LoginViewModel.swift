//
//  LoginViewModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/01
//  
//

import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    
    @Published var id = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var alertType: AlertType? = nil
    private let router: Router

    init(router: Router) {
        self.router = router
    }
    
    func login() {
        Task {
            errorMessage = ""
            let loginResult = await AuthModel.shared.login(id: id, password: password)
            switch loginResult {
            case .success(let response):
                print(response.user)
                router.selectedRoute = .tab
            case .failure(let loginError):
                errorMessage = FirebaseError.shared.getErrorMessage(loginError)
//                alertType = AlertType(title: "エラー", message: errorMessage)
                //↓ダイアログ表示、今後実装
//                FirebaseError.shared.handle(loginError)
            }
        }
    }
}
