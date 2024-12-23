//
//  NotificationService.swift
//  NotificationService
//  
//  Created by SATTSAT on 2024/12/23
//  
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    // 「リモート通知が端末に届いた後」かつ「ユーザーに通知を見せる前」のタイミングで呼ばれる
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        print("[DEBUG] Notification userInfo: \(request.content.userInfo)")
        
        guard let content = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            contentHandler(request.content)
            return
        }

        // (1) プッシュ通知のペイロードから添付ファイルのURLを取り出す
        // ペイロードのルートの`image_url`キーに対応する値がURLだと想定する
        guard let urlString = request.content.userInfo["image_url"] as? String,
            let url = URL(string: urlString) else {
            // ペイロードからurlを取り出せない場合
            contentHandler(content)
            return
        }

        // (2) 添付ファイルをダウンロードする
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            // URLの末尾が拡張子付きのファイル名であると想定する
            let fileName = url.lastPathComponent
            let writePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)

            do {
                try data?.write(to: writePath)

                // (3) 添付ファイルの保存先のURLをOSに提供する(contentHandler経由で)
                let attachment = try UNNotificationAttachment(identifier: fileName, url: writePath, options: nil)
                content.attachments = [attachment]
                contentHandler(content)
            } catch {
                print("error: \(error)")
                contentHandler(content)
            }
        })
        task.resume()
    }
}
