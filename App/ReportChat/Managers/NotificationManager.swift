//
//  NotificationManager.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/10/15
//
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import JWTKit

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    private let appManager = AppManager.shared
    
    private let center = UNUserNotificationCenter.current()
    
    @Published var notifications: [NotificationModel]? = nil
    
    private let firestore = Firestore.firestore()
    
    private init() {
        self.fetchNotifications()
    }
    
    //通知を送る処理
    func sendNotification(fcmToken: String, title: String, body: String) {
        guard let projectId = ProcessInfo.processInfo.environment["PROJECT_ID"] else {
            print("[ERROR] ProjectIdが取得できません")
            return
        }
        guard let url = URL(string: "https://fcm.googleapis.com/v1/projects/\(projectId)/messages:send") else {
            print("Invalid URL")
            return
        }
        
        let payload: [String: Any] = [
            "message": [
                "token": fcmToken,
                "notification": [
                    "title": title,
                    "body": body
                ],
                "apns": [
                    "payload": [
                        "aps": [
                            "alert": [
                                "title": title,
                                "body": body
                            ],
                            "sound": "default"
                        ]
                    ]
                ]
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            print("Failed to create JSON data")
            return
        }
        
        Task {
            let tokenResponse = await generateAccessToken()
            switch tokenResponse {
            case .success(let accessToken):
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                request.httpBody = jsonData
                
                do {
                    let (responseData, response) = try await URLSession.shared.data(for: request)
                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("Failed to cast response as HTTPURLResponse")
                        return
                    }
                    
                    if httpResponse.statusCode == 200 {
                        print("[DEBUG] 通知の送信に成功しました")
                    } else {
                        let message = String(data: responseData, encoding: .utf8) ?? "Unknown error"
                        print("[Error] 通知の送信に失敗しました。 Status code: \(httpResponse.statusCode), Message: \(message)")
                    }
                } catch {
                    print("[Error] 通知の送信に失敗しました。: \(error.localizedDescription)")
                }
            case .failure(let accessTokenError):
                print("[Error] アクセストークンの生成に失敗しました: \(accessTokenError)")
            }
        }
    }
    
    private func generateAccessToken() async -> Result<String, AccessTokenError> {
        
        let privateKeyRaw = ProcessInfo.processInfo.environment["PRIVATE_KEY"] ?? ""
        let privateKey = privateKeyRaw.replacingOccurrences(of: "\\n", with: "\n")
        let clientEmail = ProcessInfo.processInfo.environment["CLIENT_EMAIL"] ?? ""
        
        guard !privateKey.isEmpty else { return .failure(.missingPrivateKey) }
        guard !clientEmail.isEmpty else { return .failure(.invalidClientEmail) }
        
        let payload = StandardPayload(
            iss: clientEmail,
            scope: "https://www.googleapis.com/auth/firebase.messaging",
            aud: AudienceClaim(value: "https://oauth2.googleapis.com/token"),
            exp: ExpirationClaim(value: Date().addingTimeInterval(3600)),   // 1時間後まで有効
            iat: IssuedAtClaim(value: Date())
        )
        
        let keys = JWTKeyCollection()
        
        //秘密鍵の読み取り
        do {
            let key = try Insecure.RSA.PrivateKey(pem: privateKey)
            await keys.add(rsa: key, digestAlgorithm: .sha256)
        } catch {
            return .failure(.rsaKeyConversionError)
        }
        
        let jwt: String
        do {
            jwt = try await keys.sign(payload)
        } catch {
            return .failure(.signingFailed)
        }
        
        guard let url = URL(string: "https://oauth2.googleapis.com/token") else {
            return .failure(.invalidTokenUrl)
        }
        
        // URL Request
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(jwt)"
        urlRequest.httpBody = body.data(using: .utf8)
        
        //API通信
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpURLResponse = response as? HTTPURLResponse else {
                preconditionFailure()
            }
            
            switch httpURLResponse.statusCode {
            case 200:
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let token = json?["access_token"] as? String {
                        return .success(token)
                    } else {
                        return .failure(.decodingError)
                    }
                } catch {
                    return .failure(.parseError)
                }
            default:
                let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                return .failure(.responseError(code: httpURLResponse.statusCode, message: message))
            }
            
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            return .failure(.networkError)
        } catch {
            return .failure(.unknownError)
        }
    }
    
    //ユーザー通知許可状態を取得、初回表示時のみ表示
    func checkNotificationAuth(){
        Task {
            let authState = await getNotificationAuth()
            guard authState == .notDetermined else { return }
            
            await MainActor.run {
                UIApplication.showModal(modalItem: ModalItem(
                    type: .info,
                    title: "通知を許可して友達からの報告を受け取ろう",
                    description: "通知を許可することで、友達からの感情報告にいち早く気づくことができます",
                    alignment: .center,
                    isCancelable: false,
                    onTapped: {
                        self.center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                            if granted {
                                print("[DEBUG] 通知リクエストが許可されました")
                                DispatchQueue.main.async {
                                    UIApplication.shared.registerForRemoteNotifications()
                                }
                            }
                        }
                    }
                ))
            }
        }
    }
    
    //ユーザーの通知許可状況を確認
    func getNotificationAuth() async -> UNAuthorizationStatus{
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
    
    private func fetchNotifications() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        firestore.collection("notifications")
            .whereField("receiverId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("通知の取得に失敗しました: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    return
                }
                
                let fetchedNotifications = documents.compactMap { document in
                    try? document.data(as: NotificationModel.self)
                }
                
                // 新しい通知が来た場合のみトースト表示
                if let latestFetchedNotification = fetchedNotifications.first,
                   let latestStoredNotification = self.notifications?.first,
                   latestFetchedNotification.id != latestStoredNotification.id {
                    let newMessage = latestFetchedNotification.message
                    UIApplication.showToast(type: .info, message: newMessage)
                }
                
                self.notifications = fetchedNotifications
            }
    }
    
    //アナウンスの送信
    func sendAnnouncement(to userId: String, message: String) {
        let noticeType = NoticeType.announcement.rawValue
        guard let currentUser = appManager.currentUser else { return }
        let newNotification = NotificationModel(
            senderId: currentUser.id!,
            receiverId: userId,
            message: message,
            url: "",
            noticeType: noticeType,
            timestamp: Date(),
            isRead: false
        )
        do {
            _ = try firestore
                .collection("notifications")
                .addDocument(from: newNotification)
            
            print("\(userId)にアナウンスしました")
        } catch {
            print("アナウンスに失敗しました(NotificationManager) \(error.localizedDescription)")
        }
    }
    
    //友達申請通知の送信
    func sendFriendRequestNotification(to userId: String) {
        let noticeType = NoticeType.friendRequest.rawValue
        guard let currentUser = appManager.currentUser else { return }
        
        let message = "「\(currentUser.userName)」から友達申請が届いています"
        let newNotification = NotificationModel(
            senderId: currentUser.id!,
            receiverId: userId,
            message: message,
            url: "",
            noticeType: noticeType,
            timestamp: Date(),
            isRead: false
        )
        
        do {
            _ = try firestore
                .collection("notifications")
                .addDocument(from: newNotification)
            
            print("\(userId)に友達申請を送りました")
        } catch {
            print("通知の送信に失敗しました: \(error)")
        }
    }
    
    //フレンドリクエストを送っているか確認
    func checkSentFriendRequest(from senderId: String, to receiverId: String) async -> Bool {
        do {
            let snapshot = try await firestore
                .collection("notifications")
                .whereField("senderId", isEqualTo: senderId)
                .whereField("receiverId", isEqualTo: receiverId)
                .whereField("noticeType", isEqualTo: NoticeType.friendRequest.rawValue)
                .getDocuments()

            if !snapshot.isEmpty {
                return true //リクエストをすでに送っている
            }
            
            return false
            
        } catch {
            return false
        }
    }
}

struct StandardPayload: JWTPayload {
    let iss: String        // 発行者
    let scope: String      // スコープ (カスタム)
    let aud: AudienceClaim // トークンの対象者
    let exp: ExpirationClaim // 有効期限
    let iat: IssuedAtClaim   // 発行日時

    func verify(using key: some JWTKit.JWTAlgorithm) throws {
        try exp.verifyNotExpired() // 有効期限の確認
        try aud.verifyIntendedAudience(includes: "https://oauth2.googleapis.com/token")
    }
}

enum AccessTokenError: Error {
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
