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
    private let appManager = AppManager.shared
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    var currentUserId: String? {
        return auth.currentUser?.uid
    }
    
    init() {
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
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
    
    //ログアウト処理
    func handleLogout() async {
        guard let userId = auth.currentUser?.uid else {
            return
        }
        do {
            await UserServiceManager.shared.removeFCMToken(for: userId)
            try self.auth.signOut()
            appManager.stopListening()
            print("ログアウトに成功しました！")
        } catch let signOutError as NSError {
            print("ログアウトに失敗しました: %@", signOutError)
        }
    }
    
    //新規登録
    func register(id: String, password: String) async -> Result<AuthDataResult, Error> {
        do {
            let result = try await self.auth.createUser(withEmail: id, password: password)
            return .success(result)
        } catch let error as NSError {
            return .failure(error)
        }
    }
    
    //ハンドルネームがすでに存在するか確認
    func checkHandleNameAvailibility(handleName: String) async -> Result<Void, HandleNameError> {
        do {
            // FirestoreのusersコレクションでhandleNameが既に使われているか確認
            let snapshot = try await firestore.collection("users")
                .whereField("handle", isEqualTo: handleName)
                .getDocuments()
            
            // ドキュメントが存在する場合（ハンドルネームが既に使われている）
            if !snapshot.isEmpty {
                return .failure(.alreadyInUse)
            } else {
                // ドキュメントが存在しない場合（ハンドルネームが利用可能）
                return .success(())
            }
        } catch {
            // Firebaseのクエリ中にエラーが発生した場合
            print("ハンドルネーム認証でサーバーエラーが発生: \(error.localizedDescription)")
            return .failure(.serverError)
        }
    }
    
    // idからユーザー情報を取得
    func fetchUser(userId: String) async -> Result<UserResponse, UserFetchError> {
        
        do {
            let snapshot = try await firestore
                .collection("users")
                .document(userId)
                .getDocument()
            
            // snapshotをデコードしてUserResponseに変換
            return try .success(snapshot.data(as: UserResponse.self))
            
        } catch _ as DecodingError {
            return .failure(.userNotFound)
        } catch {
            return .failure(.unknown)
        }
    }
    
    // ユーザー検索メソッド
    func searchUsers(byHandle handle: String) async -> Result<[UserResponse], UserFetchError> {
        do {
            let snapshot = try await firestore.collection("users")
                .whereField("handle", isGreaterThanOrEqualTo: handle)
                .whereField("handle", isLessThanOrEqualTo: handle + "\u{f8ff}")  // 前方一致
                .getDocuments()
            
            let users = snapshot.documents.compactMap { document -> UserResponse? in
                try? document.data(as: UserResponse.self)
            }
            
            if users.isEmpty {
                return .failure(.userNotFound)
            } else {
                return .success(users)
            }
            
        } catch {
            return .failure(.unknown)
        }
    }
    
    //idからルーム内のメッセージを取得
    func fetchRoomMessages(roomID: String) async -> [MessageResponse]? {
        var messages = [MessageResponse]()
        do {
            let messagesCollection =
            firestore
                .collection("rooms")
                .document(roomID)
                .collection("messages")
                .order(by: "timestamp")
            
            let snapshot = try await messagesCollection.getDocuments()
            
            for document in snapshot.documents {
                if let message = try? document.data(as: MessageResponse.self) {
                    messages.append(message)
                }
            }
            return messages
        } catch _ as NSError {
            print("ルーム内メッセージを取得できませんでした")
            return nil
        }
    }
    
    // FireStorageにある画像を非同期で取得
    func fetchImage(urlString: String) async -> Data? {
        guard let url = URL(string: urlString) else { return nil }

        do {
            // URLSessionを使って非同期でデータを取得
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // HTTPレスポンスのステータスコードを確認（200が正常）
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                return data
            } else {
                print("不正なレスポンスコード: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                return nil
            }
        } catch {
            print("非同期の画像取得でエラー: \(error)")
            return nil
        }
    }
}
