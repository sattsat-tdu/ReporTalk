//
//  UserServiceManager.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/11/19
//  
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import FirebaseMessaging

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
    
    func deleteUser(password: String) async -> Result<Void, Error> {
        guard let deleteUser = auth.currentUser else { return .failure(CommonError.userNotFound) }
        let uid = deleteUser.uid
        
        //step0. パスワード再認証
        let checkResult = await checkPassword(deleteUser: deleteUser, password: password)
        if case .failure(let deleteAuthError) = checkResult {
            return .failure(deleteAuthError)
        }
        
        //step1. FireStorageからユーザーアイコンを削除
        let deleteUserIconResult = await deleteUserIcon(userId: uid)
        if case .failure(let userIconError) = deleteUserIconResult {
            return .failure(userIconError)
        }
        
        //step2. Firestore上からユーザーを削除
        let deleteFirestoreResult = await deleteUserData(userId: uid)
        if case .failure(let firestoreUserError) = deleteFirestoreResult {
            return .failure(firestoreUserError)
        }
        
        //step3. Auth情報の削除
        let deleteAuthResult = await deleteAuthorization(deleteUser: deleteUser)
        if case .failure(let deleteAuthError) = deleteAuthResult {
            return .failure(deleteAuthError)
        }
        print("[DEBUG] ユーザーの削除に成功(UserServiceManager.deleteUser)")
        return .success(())
    }
    
    //パスワード再認証
    private func checkPassword(deleteUser: User, password: String) async -> Result<Void, DeleteAuthError> {
        do {
            guard let email = auth.currentUser?.email else {
                return .failure(.userNotLoggedIn)
            }
            // 再認証用のクレデンシャルを作成
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            
            // 再認証
            try await deleteUser.reauthenticate(with: credential)
            return .success(())
        } catch let error as NSError {
            if error.domain == NSURLErrorDomain {
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
    
    //Auth情報の削除
    private func deleteAuthorization(deleteUser: User) async -> Result<Void, DeleteAuthError> {
        do {
            try await deleteUser.delete()
            return .success(())
        } catch {
            return .failure(.unknownError)
        }
    }
    
    //Firestoreのユーザードキュメントを削除
    private func deleteUserData(userId: String) async -> Result<Void, FirestoreUserError> {
        do {
            try await firestore.collection("users").document(userId).delete()
            appManager.stopListening()
            return .success(())
        } catch {
            return .failure(.deleteFailed)
        }
    }
    
    //アイコンを削除
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
    
    //FCMTokenを追加
    func addFCMToken(token: String) async {
        do {
            guard let userId = auth.currentUser?.uid else {
                return
            }
//            
//            guard let fcmToken = UDManager.shared.get(forKey: AppStateKeys.fcmToken) as String? else {
//                return
//            }
            try await firestore.collection("users").document(userId).updateData([
                "fcmTokens": FieldValue.arrayUnion([token]) // 配列に追加
            ])
            print("[DEBUG] FCMトークンを配列として追加しました")
        } catch {
            print("[DEBUG] FCMトークンの取得または保存に失敗しました: \(error)")
        }
    }
    
    //ログアウト時にFCM Tokenを削除
    func removeFCMToken(for userId: String) async {
        do {
            guard let fcmToken = UDManager.shared.get(forKey: AppStateKeys.fcmToken) as String? else {
                return
            }
            
            try await firestore.collection("users").document(userId).updateData([
                "fcmTokens": FieldValue.arrayRemove([fcmToken]) // 配列から削除
            ])
            print("[DEBUG] FCMトークンを配列から削除しました")
        } catch {
            print("[DEBUG] FCMトークンの削除に失敗しました: \(error)")
        }
    }
    
    //ユーザー情報の保存
    func saveUser(user: UserResponse) async -> Result<Void, FirestoreUserError> {
        guard let userId = user.id else { return .failure(.userNotFound) }
        let userData = user.toDictionary()
        do {
            let documentRef = firestore.collection("users").document(userId)
            
            try await documentRef.setData(userData, merge: true)
            return .success(())
        } catch let error as NSError {
            if error.domain == NSURLErrorDomain {
                return .failure(.networkError)
            }
            return .failure(.updateFailed)
        }
    }
    
    func updateUserIcon(imageUrl: String?) async {
        guard let userId = appManager.currentUser?.id else { return }
        
        let documentRef = Firestore.firestore().collection("users").document(userId)

        do {
            if let imageUrl {
                try await documentRef.updateData(["photoURL": imageUrl])
                print("アイコンの更新に成功しました！")
            } else {
                try await documentRef.updateData(["photoURL": FieldValue.delete()])
                print("アイコンの削除に成功しました！")
            }
        } catch {
            print("アイコンの更新に失敗しました")
        }
    }
    
    //MARK: FireStorage処理
    //FirebaseStorageに画像をアップロード
    func uploadUserIcon(userId: String, imageData: Data) async -> Result<String, FirestorageError> {
        let storageRef = storage.reference().child("userIcons/\(userId).jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"  // JPEG形式の画像を指定

        do {
            // メタデータを使用して画像データをアップロード
            let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
            let downloadURL = try await storageRef.downloadURL().absoluteString
            return .success(downloadURL)
            
        } catch let error as NSError {
            if error.domain == NSURLErrorDomain {
                return .failure(.networkError)
            }
            return .failure(.uploadFailed)
        }
    }
}
