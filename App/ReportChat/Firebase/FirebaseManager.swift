//
//  FirebaseManager.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/08/31
//  
//

import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class FirebaseManager: ObservableObject {
    //どこでも共有させる。
    static let shared = FirebaseManager()
    
    let auth: Auth
    let storage: Storage
    let fireStore: Firestore
    var currentUser: String? {
        return auth.currentUser?.uid
    }
    
    init() {
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.fireStore = Firestore.firestore()
    }
    
    //ログイン処理
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
    
    //idからユーザー情報を取得
    func fetchUser(userId: String) async -> UserResponse? {
        do {
            let snapshot = try await 
            FirebaseManager.shared.fireStore
                .collection("users")
                .document(userId)
                .getDocument()
            
            return try snapshot.data(as: UserResponse.self)
            
        } catch _ as NSError {
            print("ユーザーが見つかりませんでした。")
            return nil
        }
    }
    
    //idからルーム情報を取得
    func fetchRoom(roomID: String) async -> RoomResponse? {
        do {
            let snapshot = try await
            FirebaseManager.shared.fireStore
                .collection("rooms")
                .document(roomID)
                .getDocument()
            
            return try snapshot.data(as: RoomResponse.self)
        } catch _ as NSError {
            print("ルームが見つかりませんでした。")
            return nil
        }
    }
}
