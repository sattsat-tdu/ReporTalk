//
//  UserServiceManager.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/11/19
//  
//

//
//  UserServiceManager.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/11/19
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class UserServiceManager: ObservableObject {
    // シングルトン
    static let shared = UserServiceManager()
    private let appManager = AppManager.shared

    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    init() {
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
    }
    
    //FireStoreのアカウント情報を削除
    func deleteUserData(userId: String) async {
        do {
            try await firestore.collection("users").document(userId).delete()
            appManager.stopListening()
        } catch {
            print("FireStoreでのアカウント削除に失敗しました: \(error.localizedDescription)")
        }
    }
    
    func deleteUserIcon(userId: String) async -> Result<Void, FirestorageError> {
        let storageRef = storage.reference().child("userIcons/\(userId).jpg")
        do {
            try await storageRef.delete()
            return .success(())
        } catch let error as NSError {
            print(error)
            // アイコンが存在しない場合はそのままsuccess
            if error.domain == StorageErrorDomain,
               StorageErrorCode(rawValue: error.code) == .objectNotFound {
                return .success(())
            }
            if error.domain == NSURLErrorDomain {
                return .failure(.networkError)
            }
            return .failure(.deleteFailed)
        }
    }
    
    //Authアカウントの削除
    func deleteAuthUser(deleteUser: FirebaseAuth.User, password: String) async -> Result<Void, DeleteAuthError> {
        do {
            // 現在のユーザーのメールアドレスを取得
            guard let email = auth.currentUser?.email else {
                return .failure(.userNotLoggedIn)
            }
            
            // 再認証用のクレデンシャルを作成
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            
            // 再認証
            try await deleteUser.reauthenticate(with: credential)
            
            // 再認証成功後にユーザーを削除
            try await deleteUser.delete()
            print("認証情報の削除に成功しました")
            return .success(())
            
        } catch let error as NSError {
            // FirebaseAuthのエラーを確認
            if error.domain == NSURLErrorDomain {
                // ネットワークエラーのチェック
                return .failure(.networkError)
            }

            switch error.code {
            case AuthErrorCode.wrongPassword.rawValue,
                 AuthErrorCode.userMismatch.rawValue,
                 AuthErrorCode.invalidCredential.rawValue:
                return .failure(.wrongPassword) // パスワードが間違っている場合
            case AuthErrorCode.operationNotAllowed.rawValue:
                return .failure(.deletionFailed) // 操作が許可されていない場合
            default:
                print("エラー詳細: \(error.localizedDescription)")
                return .failure(.unknownError) // その他のエラー
            }
        }
    }
}
