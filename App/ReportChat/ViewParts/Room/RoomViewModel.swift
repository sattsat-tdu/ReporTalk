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
    let room: RoomResponse
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
        print("メッセージのリスナーが起動")
        listenForRoomMessages()
    }
    
    //メッセージViewを閉じた時にリスナーを解除
    func onMessageViewDisappear() {
        print("メッセージリスナー解除")
        listener?.remove()
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
        
        let firestore = Firestore.firestore()
        
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
            
        guard let senderId = appManager.currentUser?.id else { return }
        guard let roomId = room.id else { return }
        
        let document = FirebaseManager.shared.fireStore
            .collection("rooms")
            .document(roomId)
            .collection("messages")
        
        let messageData = MessageResponse(
            text: self.messageText,
            senderId: senderId,
            timestamp: Date()
        ).toDictionary()
        
        // addDocumentを使用して新しいメッセージを追加
        document.addDocument(data: messageData) { error in
            if let err = error {
                print("メッセージの作成に失敗: \(err)")
                return
            }
            print("メッセージの送信に成功！")
            self.messageText = ""
        }
    }
}
