//
//  RoomCellViewModel.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/09/18
//
//

import SwiftUI
import Foundation
import FirebaseFirestore

@MainActor
final class RoomViewModel: ObservableObject {
    @Published var iconUrlString: String? = nil
    @Published var isUnread = false
    @Published var roomName: String = " --- "
    @Published var messages: [MessageResponse]? = nil
    @Published var messageText = ""
    @Published var selectedReporTag: Reportag?
    var room: RoomResponse
    private let firestore = Firestore.firestore()
    private let appManager = AppManager.shared
    private var otherUsers: [UserResponse] = []
    var loginUserId: String {
        return  (appManager.currentUser?.id)!
    }
    private var messageListener: ListenerRegistration?  // メッセージのリスナー
    
    var isInitialLoad = true
    @Published var lastAddedMessageId: String? = nil
    @Published var isLoading = false
    
    init(room: RoomResponse) {
        self.room = room
        fetchRoomInfo()
        self.checkReadState()
    }
    
    deinit {
        // ViewModelが破棄される際にリスナーを削除
        messageListener?.remove()
    }
    
    //メッセージViewを開いた時にリスナーをスタート
    func onMessageViewAppear() {
        listenForRoomMessages()
        if self.isUnread {
            updateReadTime()    //未読だったらルームViewを見た時間を更新
        }
    }
    
    //メッセージViewを閉じた時にリスナーを解除
    func onMessageViewDisappear() {
        isInitialLoad = true
//        self.lastAddedMessageId = nil
        messageListener?.remove()
    }
    
    func updateRoom(with room: RoomResponse) {
        // ルームのプロパティを更新
        self.room = room
        self.roomName = room.roomName ?? self.roomName
        self.iconUrlString = room.roomIcon ?? self.iconUrlString
        self.checkReadState()
    }
    
    //未読状態なのかを確認
    private func checkReadState() {
        guard let userId = appManager.currentUser?.id,
              let lastReadTime = room.readUsers[userId] else { return }
        isUnread = room.lastUpdated > lastReadTime
    }
    
    // 相手のアイコンやルーム名を取得
    func fetchRoomInfo() {
        Task {
            guard let partner = await fetchPartner() else { return }
            otherUsers.append(partner)
            //ルームアイコンの取得
            let roomIconUrl = room.roomIcon ?? partner.photoURL
            self.iconUrlString = roomIconUrl
            
            self.roomName = partner.userName
        }
    }
    
    // 2人の時に、相手のUser情報を取得
    func fetchPartner() async -> UserResponse? {
        if room.members.count == 2 {
            guard let currentUser = FirebaseManager.shared.currentUserId else { return nil }
            guard let partnerId = room.members.first(where: { $0 != currentUser }) else { return nil }
            let partnerUserResult = await FirebaseManager.shared.fetchUser(userId: partnerId)
            switch partnerUserResult {
            case .success(let user):
                return user
            case .failure(_):
                return nil
            }
        }
        return nil
    }
    
    func listenForRoomMessages(limit: Int = 20) {
        messageListener?.remove()
        guard let roomId = room.id else { return }
        
        messageListener = firestore.collection("rooms")
            .document(roomId)
            .collection("messages")
            .order(by: "timestamp", descending: true)   //最新のものから取得
            .limit(to: limit)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print(error.localizedDescription)
                    return
                }

                guard let changes = snapshot?.documentChanges else {
                    print("No changes found.")
                    return
                }

                self.processDocumentChanges(changes)
            }
    }
    
    private func processDocumentChanges(_ changes: [DocumentChange]) {
        changes.forEach { change in
            do {
                let message = try change.document.data(as: MessageResponse.self)

                switch change.type {
                case .added:
                    if isInitialLoad {
                        setMessage(message)
                    } else {
                        addNewMessage(message)
                    }
                case .modified:
                    print("ルームデータが更新されました")
                case .removed:
                    removeMessage(message)
                }
            } catch {
                print("Error decoding message: \(error.localizedDescription)")
            }
        }
        //初回ロードの判定変数
        if isInitialLoad {
            lastAddedMessageId = messages?.last?.id
            isInitialLoad = false
        }
    }
    
    //初期データの適応
    private func setMessage(_ message: MessageResponse) {
        guard let messages = self.messages else {
            self.messages = [message]
            return
        }
        if !messages.contains(where: { $0.id == message.id }) {
//            self.messages?.insert(message, at: 0)
            self.messages?.append(message)
        }
    }
    
    //新しいメッセージ
    private func addNewMessage(_ message: MessageResponse) {
        guard let messages = self.messages else {
            self.messages = [message]
            return
        }

        if !messages.contains(where: { $0.id == message.id }) {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.messages?.insert(message, at: 0)
            }
        }
        self.lastAddedMessageId = message.id
        
        if message.senderId != self.loginUserId {
            self.updateReadTime()
        }
    }
    
    private func removeMessage(_ message: MessageResponse) {
        self.messages?.removeAll(where: { $0.id == message.id })
    }
    
    private var hasMoreMessages = true
    
    //さらに取得
    @MainActor
    func fetchMoreMessages(limit: Int = 10) async {
        
        guard !isLoading else { return }
        guard hasMoreMessages, let roomId = room.id, let firstMessage = messages?.last else { return }

        print("取得します")
        let firstTimestamp = firstMessage.timestamp.addingTimeInterval(-1)
        let firstId = firstMessage.senderId
        isLoading = true
        do {
            let snapshot = try await firestore.collection("rooms")
                .document(roomId)
                .collection("messages")
                .order(by: "timestamp", descending: true)
                .order(by: "senderId", descending: true)
            
                .start(after: [firstTimestamp, firstId])
                .limit(to: limit)
                .getDocuments()
            
            let newMessages = snapshot.documents.compactMap { document -> MessageResponse? in
                return try? document.data(as: MessageResponse.self)
            }
            // メッセージが空なら、もう取得するものがないと判断
            if newMessages.isEmpty {
                hasMoreMessages = false
                self.isLoading = false
                return
            }

            DispatchQueue.main.async { [self] in
                self.messages?.append(contentsOf: newMessages)
                self.lastAddedMessageId = messages?.last?.id
                self.isLoading = false
            }
        } catch {
            print("Error fetching more messages: \(error.localizedDescription)")
        }
    }
    
    //ルームのTimestampを更新してからメッセージを送る処理
    func handleSend() {
        let fcmManager = FCMManager()
        let message = self.messageText
        let reporTag = self.selectedReporTag
        if message == "" {
            print("テキストが空です。")
            return
        }
        guard let userId = appManager.currentUser?.id else { return }
        guard let roomId = room.id else { return }
        
        //レポータグが存在するなら、SwiftDataへ保存
        if let reporTag {
            let reporTagMessage = ReporTagMessage(
                userId: userId,
                reportag: reporTag,
                message: messageText,
                timestamp: Date(),
                rId: roomId,
                roomName: roomName,
                roomIcon: iconUrlString ?? ""
            )
            SwiftDataManager.shared.insert(reporTagMessage)
        }
        // メッセージ入力欄とタグ選択をクリア
        self.messageText = ""
        self.selectedReporTag = nil
        
        Task {
            let updateResult = await RoomManager.shared.sendMessageWithBatch(
                roomId: roomId,
                reportag: reporTag,
                message: message)
            switch updateResult {
            case .success:
                print("ルームの全ての更新に成功しました")
                //通知処理、対象ユーザーに通知を送信
                guard let title = appManager.currentUser?.userName else {
                    print("ログインユーザー名の取得に失敗")
                    return
                }
                let imageUrl = appManager.currentUser?.photoURL
                let body: String
                if let tagName = reporTag?.tagName {
                    body = "【\(tagName)】\n\(message)"
                } else {
                    body = message
                }
                for user in otherUsers {
                    for token in user.fcmTokens {
                        fcmManager.sendNotification(
                            fcmToken: token,
                            title: title,
                            body: body,
                            imageUrl: imageUrl
                        )
                    }
                }
                
            case .failure(let error):
                print(error.rawValue)
            }
        }
    }
    
    //readUsersの時間を更新
    func updateReadTime() {
        print("更新処理が呼ばれました")
        guard let roomId = room.id else { return }
        
        Task {
            let updateResult = await RoomManager.shared.updateUserReadTime(roomId: roomId, date: Date())
            if case .failure(let error) = updateResult {
                print(error.rawValue)
            }
        }
    }
}
