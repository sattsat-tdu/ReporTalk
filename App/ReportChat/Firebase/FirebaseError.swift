import SwiftUI
import UIKit

enum CommonError:String, Error {
    case userNotFound = "ログインユーザーが見つかりません"
}

//通知に関する処理
enum AccessTokenError: Error {
    case fetchPlistError
    case rsaKeyConversionError
    case missingPrivateKey
    case invalidClientEmail
    case signingFailed
    case invalidTokenUrl
    case decodingError
    case parseError
    case responseError(code: Int, message: String)
    case networkError
    case unknownError
}

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

// アカウント削除時のハンドリング
enum DeleteAuthError: String, Error {
    case wrongPassword = "パスワードが間違っています。"
    case reauthenticationFailed = "再認証に失敗しました。"
    case deletionFailed = "アカウント削除が許可されていません。"
    case userNotLoggedIn = "ログイン中のユーザーが見つかりません。"
    case networkError = "ネットワーク接続に問題があります。"
    case unknownError = "不明なエラーが発生しました。"
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

enum FirestorageError: String, Error {
    case uploadFailed = "画像のアップロードに失敗しました"
    case networkError = "ネットワークに接続されていません"
    case deleteFailed = "画像の削除に失敗しました"
}

enum UserFetchError: String, Error {
    case authDataNotFound = "認証データが見つかりません"
    case userNotFound = "ユーザー情報がありません"
    case networkError = "ネットワークに接続できません。"
    case unknown = "予期せぬエラー"
    
    var errorDescription: String {
        switch self {
        case .authDataNotFound:
            "ユーザー認証に失敗しました。\n再度ログインしてください。"
        case .userNotFound:
            "ユーザー情報の登録ができていないようです。\nプロフィールの入力をお願いいたします。"
        case .networkError:
            "接続を確認してください。\nやり直すには「はい」をタップしてください。"
        case .unknown:
            "ユーザー取得時に予期せぬエラーが発生しました。"
        }
    }
}

//FireStore上でのユーザー情報の作成・更新・削除のエラーハンドリング
enum FirestoreUserError: String, Error {
    case userNotFound = "ユーザー情報が読み込めません。"
    case updateFailed = "ユーザー情報を更新できませんでした。"
    case deleteFailed = "ユーザー情報をデータベースから削除できませんでした"
    case networkError = "ネットワークに接続できません。"
}


enum AddIdError: String, Error {
    case userNotFound = "ユーザー情報が読み込めません。"
    case otherUserNotFound = "追加先のユーザー情報が読み込めません。"
    case alreadyExists = "すでに追加しています。"
    case invalidData = "データが不正です。"
    case serverError = "サーバーエラーが発生しました。"
    case unknownError = "追加時に不明なエラーが発生しました。"
}

enum FriendManagerError: String, Error {
    case userNotFound = "ユーザー情報が読み込めません。"
    case otherUserNotFound = "追加先のユーザー情報が読み込めません。"
    case alreadyExists = "すでに追加しています。"
    case updateFailed = "友達リストを更新できませんでした。"
    case serverError = "サーバーエラーが発生しました。"
    case unknownError = "追加時に不明なエラーが発生しました。"
}

enum RoomManagerError: String, Error {
    case userNotFound = "ユーザー情報が読み込めません。"
    case roomNotFound = "ルーム情報が読み込めません。"
    case roomsFetchError = "ルーム一覧の取得に失敗しました。"
    case otherUserNotFound = "追加先のユーザー情報が読み込めません。"
    case alreadyExists = "すでに追加しています。"
    case updateFailed = "ルームリストを更新できませんでした。"
    case serverError = "サーバーエラーが発生しました。"
    case unknownError = "追加時に不明なエラーが発生しました。"
}

enum RemoveIdError: String, Error {
    case userNotFound = "ユーザー情報が読み込めません。"
    case otherUserNotFound = "削除先のユーザー情報が読み込めません。"
    case notFound = "削除対象が存在しません。"
    case invalidData = "データが不正です。"
    case serverError = "サーバーエラーが発生しました。"
    case unknownError = "削除時に不明なエラーが発生しました。"
}

class FirebaseError {
    static let shared = FirebaseError()
    
    // エラーメッセージを取得するメソッド
    private func getErrorMessage(_ error: Error) -> String {
        switch error {
        case let commonError as CommonError:
            return commonError.rawValue
        case let authError as FirebaseAuthError:
            return authError.errorMessage
        case let deleteAuthError as DeleteAuthError:
            return deleteAuthError.rawValue
            
        case let loginError as FirebaseLoginError:
            return loginError.errorDescription
            
        case let userFetchError as UserFetchError:
            return userFetchError.rawValue
            
        case let friendMangerError as FriendManagerError:
            return friendMangerError.rawValue
            
        case let roomManagerError as RoomManagerError:
            return roomManagerError.rawValue
            
        case let firestoreUserError as FirestoreUserError:
            return firestoreUserError.rawValue
            
        case let firestorageError as FirestorageError:
            return firestorageError.rawValue
            
        default:
            return "不明なエラーが発生しました: \(error.localizedDescription)"
        }
    }
    
    func showErrorToast(_ error: Error) {
        UIApplication.showToast(type: .error, message: getErrorMessage(error))
    }
}
