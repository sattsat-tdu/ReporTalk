//
//  AuthModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/01
//  
//

import Foundation
import FirebaseAuth

final class AuthModel {
    // MARK: - シングルトン
    static let shared = AuthModel()
    
    // MARK: - リファレンス
    private let auth = Auth.auth()
    
    var currentUser: User? {
        return self.auth.currentUser
    }
    
    @MainActor
    func login(id: String, password: String) async -> Result<AuthDataResult, Error> {
        do {
            let result = try await self.auth.signIn(withEmail: id, password: password)
            return .success(result)
        } catch let error as NSError {
            if let loginAuthErrorCode = AuthErrorCode(rawValue: error.code) {
                print(error)
                switch loginAuthErrorCode {
                case .invalidEmail:
                    return .failure(FirebaseLoginError.invalidEmail)
                case .wrongPassword:
                    return .failure(FirebaseLoginError.wrongPassword)
                case .userNotFound:
                    return .failure(FirebaseLoginError.userNotFound)
                case .userDisabled:
                    return .failure(FirebaseLoginError.userDisabled)
                case .networkError:
                    return .failure(FirebaseLoginError.networkError)
                case .emailAlreadyInUse:
                    return .failure(FirebaseLoginError.emailAlreadyUse)
                case .invalidCredential:
                    return .failure(FirebaseLoginError.invalidCredential)
                default:
                    return .failure(FirebaseLoginError.unknownError)
                }
            }
            return .failure(FirebaseLoginError.unknownError)
        }
    }
        
    func mapErrorToFirebaseAuthError(_ error: NSError) -> FirebaseAuthError {
        switch error.code {
        case AuthErrorCode.userNotFound.rawValue:
            return .userNotFound
        case AuthErrorCode.userDisabled.rawValue:
            return .userDisabled
        case AuthErrorCode.requiresRecentLogin.rawValue:
            return .requiresRecentLogin
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .emailAlreadyInUse
        case AuthErrorCode.invalidEmail.rawValue:
            return .invalidEmail
        case AuthErrorCode.wrongPassword.rawValue:
            return .wrongPassword
        case AuthErrorCode.tooManyRequests.rawValue:
            return .tooManyRequests
        case AuthErrorCode.expiredActionCode.rawValue:
            return .expiredActionCode
        default:
            return .unknown
        }
    }
}
