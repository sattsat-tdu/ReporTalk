//
//  WelcomeViewModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/30
//  
//

import Foundation
import SwiftUI

@MainActor
final class WelcomeViewModel: ObservableObject {
    
    @Published var welcomeRouter: WelcomeRouter = .welcome
    @Published var handle = ""
    @Published var id = ""
    @Published var password = ""
    @Published var userName = ""
    @Published var imageData: Data?
    @Published var welcomeSettingsFlg = false
    private var userId: String?
    private let router: Router

    init(router: Router) {
        self.router = router
    }
    
    func navigate(to newRoute: WelcomeRouter) {
        withAnimation(.easeInOut) {
            self.welcomeRouter = newRoute
        }
    }
    
    func login() {
        Task {
            UIApplication.showLoading()
            let loginResult = await FirebaseManager.shared.login(id: id, password: password)
            UIApplication.hideLoading()
            switch loginResult {
            case .success(let response):
                print(response.user)
                router.selectedRoute = .tab
            case .failure(let loginError):
                UIApplication.showToast(type: .error, message: FirebaseError.shared.getErrorMessage(loginError))
            }
        }
    }
    
    func register() {
        UIApplication.showLoading(message: "アカウントを作成中...")
        self.router.stopListeningAuthChange() //認証状態を一時的に停止
        Task {
            let registerResult = await FirebaseManager.shared.register(id: self.id, password: self.password)
            switch registerResult {
            case .success(let response):
                self.userId = response.user.uid
                UIApplication.hideLoading()
                self.welcomeSettingsFlg.toggle()
            case .failure(let registerError):
                UIApplication.hideLoading()
                UIApplication.showToast(type: .error, message: registerError.localizedDescription)
            }
        }
    }
    
    func addUserToFirestore() {
        UIApplication.showLoading()
        Task {
            guard let uid = self.userId else { print("addUserToFireStore(WelcomeViewModel)"); return }
            let imageUrl = await self.uploadImage(uid: uid) // 画像アップロード
            let userData = UserResponse(
                handle: self.handle,
                userName: self.userName,
                email: self.id,
                friends: [],
                photoURL: imageUrl, // 画像のURLがある場合のみ追加
                rooms: []
            ).toDictionary()
            
            
            try await FirebaseManager.shared.fireStore.collection("users")
                .document(uid).setData(userData)
            
            self.router.startListeningAuthChange() //認証状態の監視を再開
            UIApplication.showToast(type: .success, message: "登録が完了しました！")
            UIApplication.hideLoading()
        }
    }
    
    //FireStorageに画像をアップロード
    func uploadImage(uid: String) async -> String? {
        guard let imageData = self.imageData else { return nil }
        let imageResult = await FirebaseManager.shared.uploadImage(userId: uid, imageData: imageData)
        switch imageResult {
        case .success(let imageUrl):
            return imageUrl
        case .failure(let uploadError):
            UIApplication.showToast(type: .error, message: uploadError.localizedDescription)
            return nil
        }
    }
}
