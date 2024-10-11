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
    
    //ハンドルネームが使用可能か判定
    func validateHandleName(for handleName: String){
        
        self.handleState = .loading
        self.handleErrorMessage = ""
        
        if handleName.isEmpty {
            return
        }
        
        // 1. 文頭または文末に (_) または (.) がないか判定
        if let firstChar = handleName.first, let lastChar = handleName.last {
            // 文頭または文末が (_) または (.) ならエラーを返す
            if firstChar == "_" || firstChar == "." || lastChar == "_" || lastChar == "." {
                setError(.invalidBoundaryCharacter)
                return
            }
        }
        
        // 追加: ハンドルネーム全体が (_) または (.) だけで構成されていないかをチェック
        let allDotsOrUnderscoresRegex = "^[_.]+$"
        if NSPredicate(format: "SELF MATCHES %@", allDotsOrUnderscoresRegex).evaluate(with: handleName) {
            setError(.invalidBoundaryCharacter)
            return
        }
        // 2. 大文字判定
        let uppercaseRegex = ".*[A-Z]+.*"  // 文字列中に大文字が含まれているかをチェック
        if NSPredicate(format: "SELF MATCHES %@", uppercaseRegex).evaluate(with: handleName) {
            setError(.containsUppercase)
            return
        }
        
        // 3. 数字のみの登録
        let numberRegex = "^[0-9]+$"  // 完全に数字のみかどうかをチェック
        if NSPredicate(format: "SELF MATCHES %@", numberRegex).evaluate(with: handleName) {
            setError(.onlyNumber)
            return
        }
        
        // 4. 禁止文字の判定
        let regexPattern = "^[a-z0-9_.]+$"
        let regex = NSPredicate(format: "SELF MATCHES %@", regexPattern)
        if !regex.evaluate(with: handleName) {
            setError(.invalidFormat)
            return
        }
        
        // 5. 長さ制限チェック - 短すぎないか
        if handleName.count < 6 {
            setError(.tooShort)
            return
        }
        
        // 6. 長さ制限チェック - 長すぎないか
        if handleName.count > 20 {
            setError(.tooLong)
            return
        }
        
        // 7. 被りがないかチェック
        Task {
            let checkResult = await FirebaseManager.shared.checkHandleNameAvailibility(handleName: handleName)
            DispatchQueue.main.async {
                switch checkResult {
                case .success:
                    self.handleState = .success
                    self.handleErrorMessage = "唯一無二のユーザーIDです！"
                case .failure(let error):
                    self.setError(error)
                }
            }
        }
    }
    
    // エラーメッセージを設定するメソッド
    private func setError(_ error: HandleNameError) {
        self.handleState = .error
        self.handleErrorMessage = error.rawValue
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
