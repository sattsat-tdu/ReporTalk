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
    var currentUserId: String? {
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
    
    //ログアウト処理
    func handleLogout() async {
        do {
            try self.auth.signOut()
            UserManager.shared.clearUserCache()
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
            let snapshot = try await fireStore.collection("users")
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

    func deleteAuthUser(deleteUser: FirebaseAuth.User) async {
        do {
            try await deleteUser.delete()
        } catch {
            print("認証情報の削除に失敗しました: \(error.localizedDescription)")
        }
    }
    
    func deleteUserData(userId: String) async {
        do {
            try await fireStore.collection("users").document(userId).delete()
            UserManager.shared.clearUserCache()
        } catch {
            print("FireStoreでのアカウント削除に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // idからユーザー情報を取得
    func fetchUser(userId: String) async -> Result<UserResponse, UserFetchError> {
        
        do {
            let snapshot = try await FirebaseManager.shared.fireStore
                .collection("users")
                .document(userId)
                .getDocument()
            
            print("userId: \(userId)\nでログインしています。")
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
            let snapshot = try await fireStore.collection("users")
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
    
    //idからルーム情報を取得
    func fetchRoom(roomID: String) async -> RoomResponse? {
        do {
            let snapshot = try await self.fireStore
                .collection("rooms")
                .document(roomID)
                .getDocument()
            
            return try snapshot.data(as: RoomResponse.self)
        } catch _ as NSError {
            print("ルームが見つかりませんでした。")
            return nil
        }
    }
    
    // プライベートなルームの作成・存在していればfetchする
    func fetchPrivateRoom(partnerId: String) async -> RoomResponse? {
        guard let currentUserId = self.currentUserId else { return nil }
        
        let sortedUIDs = [currentUserId, partnerId].sorted()
        let roomId = "\(sortedUIDs[0])_\(sortedUIDs[1])"
        
        do {
            // ルームが存在するかチェック
            let snapshot = try await self.fireStore
                .collection("rooms")
                .document(roomId)
                .getDocument()
            
            if snapshot.exists {
                // ルームが見つかった場合はそのルームを返す
                return try snapshot.data(as: RoomResponse.self)
            } else {
                // ルームが存在しない場合、新しいルームを作成する
                let newRoom = RoomResponse(
                    id: roomId, // ルームIDを設定
                    members: [currentUserId, partnerId],
                    roomIcon: nil,
                    roomName: nil
                )

                try await self.fireStore
                    .collection("rooms")
                    .document(roomId)
                    .setData(newRoom.toDictionary())
                
                print("新しいルームを作成しました: \(roomId)")
                
                return newRoom
            }
            
        } catch {
            print("ルームの作成に失敗しました: \(error.localizedDescription)")
            return nil
        }
    }
    
    //idからルーム内のメッセージを取得
    func fetchRoomMessages(roomID: String) async -> [MessageResponse]? {
        var messages = [MessageResponse]()
        do {
            let messagesCollection =
            FirebaseManager.shared.fireStore
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
    
    //FirebaseStorageに画像をアップロード
    func uploadImage(userId: String, imageData: Data) async -> Result<String, Error> {
        let storageRef = storage.reference().child("userIcons/\(userId).jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"  // JPEG形式の画像を指定

        do {
            // メタデータを使用して画像データをアップロード
            let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
            let downloadURL = try await storageRef.downloadURL().absoluteString
            return .success(downloadURL)
            
        } catch let error as NSError {
            return .failure(error)
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
    
    func deleteUserImage(userId: String) async {
        let storageRef = storage.reference().child("userIcons/\(userId).jpg")
        
        do {
            try await storageRef.delete()
        } catch {
            print("FireStorageでのアイコン削除に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // URLSessionを使ってネットワーク接続を確認
    func checkNetworkConnection() async -> Bool {
        let url = URL(string: "https://www.google.com")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // 接続が成功した場合
                print("ネットワーク接続に成功しました。")
                return true
            } else {
                // 無効なレスポンスの場合
                print("無効なレスポンスを受け取りました。")
                return false
            }
        } catch {
            // その他のエラーをキャッチ
            print("接続エラーが発生しました: \(error.localizedDescription)")
            return false
        }
    }
}
