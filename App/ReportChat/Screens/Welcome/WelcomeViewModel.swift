//
//  WelcomeViewModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/30
//  
//

import Foundation
import SwiftUI
import Combine
import SwiftUIFontIcon

enum WelcomeStep: Int, CaseIterable {
    case userIdSetting
    case userNameSetting
    case iconSetting
    case finishSetting
    
    var nextStep: WelcomeStep? {
        if let nextStep = WelcomeStep(rawValue: self.rawValue + 1) {
            return nextStep
        } else {
            return nil
        }
    }
    
    var previousStep: WelcomeStep? {
        if let previousStep = WelcomeStep(rawValue: self.rawValue - 1) {
            return previousStep
        } else {
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .userIdSetting:
            return "ユーザーIDを設定しましょう！"
        case .userNameSetting:
            return "ニックネームを教えてください！"
        case .iconSetting:
            return "アイコンを設定しましょう！"
        case .finishSetting:
            return "それでは、始めましょう！"
        }
    }
    
    var description: String {
        switch self {
        case .userIdSetting:
            return "ユーザー検索・追加に使用します。\n（いつでも変更可能です）"
        case .userNameSetting:
            return "ここで設定した名前は公開されます。"
        case .iconSetting:
            return "友達があなたを見つけやすくなります。"
        case .finishSetting:
            return "設定項目は、後から変更できます。 "
        }
    }
}

@MainActor
final class WelcomeViewModel: ObservableObject {
    @Published var welcomeRouter: WelcomeRouter = .welcome
    @Published var handle = ""
    @Published var handleState: HandleState = .loading
    @Published var handleErrorMessage = ""
    @Published var id = ""
    @Published var password = ""
    @Published var userName = ""
    @Published var imageData: Data?
    private var userId: String?
    private let router: Router
    private var handleNameObserver: AnyCancellable?
    @Published var isValidHandle = false

    init(router: Router) {
        self.router = router
        
        //ハンドルネームの監視
        handleNameObserver = $handle
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .removeDuplicates() // 重複する入力値は無視
            .sink(receiveValue: validateHandleName)
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
                await UserServiceManager.shared.addFCMToken(for: response.user.uid)
                router.selectedRoute = .tab
            case .failure(let loginError):
                FirebaseError.shared.showErrorToast(loginError)
            }
        }
    }
    
    func register() {
        UIApplication.showLoading(message: "アカウントを作成中...")
        Task {
            let registerResult = await FirebaseManager.shared.register(id: self.id, password: self.password)
            switch registerResult {
            case .success(let response):
//                self.userId = response.user.uid
                await UserServiceManager.shared.addFCMToken(for: response.user.uid)
                UIApplication.hideLoading()
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
            guard let authUser = FirebaseManager.shared.auth.currentUser else {
                print("Error:addUserToFireStore(WelcomeViewModel)")
                return
            }
            
            let imageUrl = await self.uploadImage(uid: authUser.uid) // 画像アップロード
            let userData = UserResponse(
                handle: self.handle,
                userName: self.userName,
                email: authUser.email ?? "ErrorEmail",
                fcmTokens: [],
                statusMessage: "",
                friends: [],
                photoURL: imageUrl, // 画像のURLがある場合のみ追加
                rooms: []
            ).toDictionary()
            
            do {
                try await FirebaseManager.shared.firestore.collection("users")
                    .document(authUser.uid).setData(userData)
                
                DispatchQueue.main.async {
                    AppManager.shared.listenToUserUpdates()
                    UIApplication.showToast(type: .success, message: "登録が完了しました！")
                    UIApplication.hideLoading()
                    self.router.switchRootView(to: .tab) // UI更新はメインスレッドで実行
                }
            } catch {
                DispatchQueue.main.async {
                    UIApplication.showToast(type: .error, message: "ユーザー情報の保存に失敗しました。")
                    UIApplication.hideLoading()
                }
            }
        }
    }
    
    //FireStorageに画像をアップロード
    func uploadImage(uid: String) async -> String? {
        guard let imageData = self.imageData else { return nil }
        let imageResult = await UserServiceManager.shared.uploadUserIcon(userId: uid, imageData: imageData)
        switch imageResult {
        case .success(let imageUrl):
            return imageUrl
        case .failure(let uploadError):
            UIApplication.showToast(type: .error, message: uploadError.localizedDescription)
            return nil
        }
    }
}
