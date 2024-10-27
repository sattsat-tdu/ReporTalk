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
    @Published var roomName: String = " --- "
    @Published var messages: [MessageResponse]? = nil
    @Published var lastMessageId: String? = nil
    @Published var messageText = ""
    var room: RoomResponse
    private let firestore = Firestore.firestore()
    private let appManager = AppManager.shared
    var loginUserId: String {
        return  (appManager.currentUser?.id)!
    }
    private var listener: ListenerRegistration?  // メッセージのリスナー
    
    init(room: RoomResponse) {
        self.room = room
        fetchRoomInfo()
    }
    
    deinit {
        // ViewModelが破棄される際にリスナーを削除
        listener?.remove()
    }
    
    //メッセージViewを開いた時にリスナーをスタート
    func onMessageViewAppear() {
        listenForRoomMessages()
    }
    
    //メッセージViewを閉じた時にリスナーを解除
    func onMessageViewDisappear() {
        listener?.remove()
    }
    
    func updateRoom(with room: RoomResponse) {
        // ルームのプロパティを更新
        self.room = room
        self.roomName = room.roomName ?? self.roomName
        self.roomIconUrlString = room.roomIcon ?? self.roomIconUrlString
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
        guard let roomId = room.id else { return }
        
        listener = firestore.collection("rooms")
            .document(roomId)
            .collection("messages")
            .order(by: "timestamp", descending: false)  // メッセージをタイムスタンプ順に取得
            .addSnapshotListener { snapshot, error in
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
                
                self.lastMessageId = self.messages?.last?.id
            }
    }
    
    func handleSend() {
        if messageText == "" {
            print("テキストが空です。")
            return
        }
        
        guard let roomId = room.id else { return }
        
        Task {
            await FirebaseManager.shared.sendMessage(roomId: roomId, message: self.messageText)
            // メッセージ送信後にルームのlastUpdatedを更新
            let updateResult = await RoomManager.shared.updateRoomLastUpdated(roomId: roomId)
            switch updateResult {
            case .success:
                print("ルームのlastUpdatedが更新されました")
            case .failure(let error):
                print("ルームのlastUpdatedの更新に失敗しました: \(error.localizedDescription)")
            }
            // メッセージ入力欄をクリア
            self.messageText = ""
        }
    }
}
