import SwiftUI
import UIKit

//認証に関するエラー
enum FirebaseAuthError: Error {
    case userNotFound
    case userDisabled
    case requiresRecentLogin
    case emailAlreadyInUse
    case invalidEmail
    case wrongPassword
    case tooManyRequests
    case expiredActionCode
    case unknown
    
    var errorMessage: String {
        switch self {
        case .userNotFound:
            return "指定されたユーザーは登録されていません。"
        case .userDisabled:
            return "指定されたユーザーは無効化されています。"
        case .requiresRecentLogin:
            return "アカウント削除などのセキュアな操作を行うにはログインによる再認証が必要です。"
        case .emailAlreadyInUse:
            return "既に利用されているメールアドレスです。"
        case .invalidEmail:
            return "不正なメールアドレスです。"
        case .wrongPassword:
            return "メールアドレス、またはパスワードが間違っています。"
        case .tooManyRequests:
            return "アクセスが集中しています。少し時間を置いてから再度お試しください。"
        case .expiredActionCode:
            return "メールアドレスリンクの期限が切れています。再度認証メールを送信してください。"
        case .unknown:
            return "予期しないエラーが発生しました。"
        }
        
        
    }
}

//Firebaseログインに関するエラー
enum FirebaseLoginError: Error, LocalizedError {
    case invalidEmail
    case wrongPassword
    case userNotFound
    case userDisabled
    case networkError
    case emailAlreadyUse
    case invalidCredential
    case unknownError
    
    var errorDescription: String {
        switch self {
        case .invalidEmail:
            return "メールアドレスの形式が正しくありません。"
        case .wrongPassword:
            return "パスワードが間違っています。"
        case .userNotFound:
            return "ユーザーが見つかりません。"
        case .userDisabled:
            return "アカウントが無効化されています。"
        case .networkError:
            return "ネットワーク接続に問題があります。"
        case .emailAlreadyUse:
            return "このメールアドレスはすでに使用されています。"
        case .invalidCredential:
            return "メールアドレスとパスワードをもう一度確認してください。"
        case .unknownError:
            return "不明なエラーが発生しました。"
        }
    }
}

enum UserFetchError: String, Error {
    case userNotFound = "ユーザー情報がありません"
    case unknown = "予期せぬエラー"
    
    var errorDescription: String {
        switch self {
        case .userNotFound:
            "ユーザー情報の登録ができていないようです。\nプロフィールの入力をお願いいたします。"
        case .unknown:
            "ユーザー取得時に予期せぬエラーが発生しました。"
        }
    }
}

class FirebaseError {
    static let shared = FirebaseError()
    
    func handle(_ error: Error) {

    }
    
    func getErrorMessage(_ error: Error) -> String {
        switch error {
        case _ as FirebaseAuthError:
//            handleAuthError(authError)
            return "はにゃ"
            
        case let loginError as FirebaseLoginError:
            return loginError.errorDescription
            
        default:
            return "不明なエラーが発生しました: \(error.localizedDescription)"
        }
    }
}

enum HandleNameError: String, Error {
    case alreadyInUse = "すでに利用されています。"
    case invalidBoundaryCharacter = "文頭や文末に (_) または (.) を使用できません。"
    case invalidFormat = "(_)と(.)以外の特殊文字は禁止されています。"
    case tooShort = "6文字以上にしてください。"
    case tooLong = "20文字以内にしてください。"
    case onlyNumber = "数字のみの登録はできません"
    case containsUppercase = "大文字が含まれています。"
    case serverError = "サーバーエラーが発生しています。"
}
