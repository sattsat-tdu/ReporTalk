//
//  RoomCellViewModel.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/09/18
//
//

import Foundation
import FirebaseFirestore

@MainActor
final class RoomViewModel: ObservableObject {
    @Published var roomIconUrlString: String? = nil
    @Published var iconUrlString: String? = nil
    @Published var isUnread = false
    @Published var roomName: String = " --- "
    @Published var messages: [MessageResponse]? = nil
    @Published var lastMessageId: String? = nil
    @Published var messageText = ""
    @Published var selectedReporTag: Reportag?
    var room: RoomResponse
    private let firestore = Firestore.firestore()
    private let appManager = AppManager.shared
    var loginUserId: String {
        return  (appManager.currentUser?.id)!
    }
    private var messageListener: ListenerRegistration?  // メッセージのリスナー
    
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
        messageListener?.remove()
//        if self.isUnread {
//            print("閉じた際に更新しました")
//            updateReadTime()    //開いた後にメッセージに変化があれば更新
//        }
    }
    
    func updateRoom(with room: RoomResponse) {
        // ルームのプロパティを更新
        self.room = room
        self.roomName = room.roomName ?? self.roomName
        self.roomIconUrlString = room.roomIcon ?? self.roomIconUrlString
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
    
    // リアルタイムでルーム内のメッセージを取得する
    func listenForRoomMessages() {
        // 既存のリスナーを削除
        messageListener?.remove()
        guard let roomId = room.id else { return }
        var isInitialLoad = true
        
        messageListener = firestore.collection("rooms")
            .document(roomId)
            .collection("messages")
            .order(by: "timestamp", descending: false)  // メッセージをタイムスタンプ順に取得
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error listening for messages: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No documents found.")
                    return
                }
                
                // Firestoreから取得したデータをMessageResponseに変換
                self.messages = documents.compactMap { document in
                    try? document.data(as: MessageResponse.self)
                }
                
                if let newMessage = self.messages?.last {
                    self.lastMessageId = newMessage.id
                    // ユーザーがRoomViewにいる場合、readUsersを更新
                    if !isInitialLoad {
                        handleAddedMessage(newMessage)
                    } else {
                        isInitialLoad = false
                    }
                }
            }
    }
    
    // メッセージが追加されたときの処理
    private func handleAddedMessage(_ message: MessageResponse) {
        guard let userId = appManager.currentUser?.id else { return }
        
        if message.senderId != userId {
            self.updateReadTime()
        }
    }
    
    //ルームのTimestampを更新してからメッセージを送る処理
    func handleSend() {
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
                reportag: reporTag.rawValue,
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
