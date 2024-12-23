//
//  FCMManager.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/12/23
//  
//

import Foundation
import JWTKit

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


final class FCMManager {
    
    //通知を送る処理
    func sendNotification(fcmToken: String, title: String, body: String, imageUrl: String?) {
        
        guard let keys = Bundle.main.infoDictionary?["Keys"] as? [String: Any],
              let projectId = keys["PROJECT_ID"] as? String else {
            print("[ERROR] PROJECT_IDが取得できません")
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
                            "sound": "default",
                            "badge": 1,
                            "mutable-content": 1
                        ],
                        "image_url": "https://firebasestorage.googleapis.com/v0/b/report-chat-c8514.appspot.com/o/Reportans%2Fanger.png?alt=media&token=3d797232-57fc-4a82-a3d5-e0cdc1fb5699"
                    ],
                    "headers": [
                        "apns-priority": "10",
                        "apns-expiration": "\(Int(Date().timeIntervalSince1970 + 3600))"
                    ]
                ],
                "android": [
                    "notification": [
                        "sound": "default",
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
                    let (data, response) = try await URLSession.shared.data(for: request)
                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("Failed to cast response as HTTPURLResponse")
                        return
                    }
                    switch httpResponse.statusCode {
                    case 200:
                        print("[DEBUG] 通知の送信に成功しました")
                    case 400:
                        print("[ERROR] リクエストが無効です。ペイロードまたはトークンを確認してください")
                    case 401:
                        print("[ERROR] アクセス権がありません。認証情報を確認してください")
                    case 403:
                        print("[ERROR] アクセス権が拒否されました。プロジェクトやトークンを確認してください\nFCM Token:\n\(fcmToken)")
                    case 404:
                        print("[ERROR] FCM Tokenが無効です。ユーザーのデバイスから登録が解除された可能性があります。\nFCM Token:\n\(fcmToken)")
                    case 500:
                        print("[ERROR] サーバー内部エラー。再試行してください")
                    case 503:
                        print("[ERROR] サーバーが一時的に利用できません。後で再試行してください")
                    default:
                        let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                        print("[ERROR] 通知の送信に失敗しました。Unknown Status code: \(httpResponse.statusCode), Message:\n\(message)")
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

        guard let infoKeys = Bundle.main.infoDictionary?["Keys"] as? [String: Any] else {
            print("[ERROR] Keys.plistが取得できません")
            return .failure(.fetchPlistError)
        }
        guard let privateKeyRaw = infoKeys["PRIVATE_KEY"] as? String else {
            print("[ERROR] PRIVATE_KEYが取得できません")
            return .failure(.missingPrivateKey)
        }
        let privateKey = privateKeyRaw.replacingOccurrences(of: "\\n", with: "\n")
        
        guard let clientEmail = infoKeys["CLIENT_EMAIL"] as? String else {
            print("[ERROR] CLIENT_EMAILが取得できません")
            return .failure(.invalidClientEmail)
        }
        
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
}
