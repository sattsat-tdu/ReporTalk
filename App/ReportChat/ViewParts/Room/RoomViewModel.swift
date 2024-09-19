//
//  RoomCellViewModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/18
//  
//

import Foundation

@MainActor
final class RoomViewModel: ObservableObject {
    @Published var roomIconData: Data? = nil
    @Published var roomName: String = " --- "
    @Published var messages: [MessageResponse]? = nil
    private let room: RoomResponse
    let currentUser = FirebaseManager.shared.currentUser
    
    init(room: RoomResponse) {
        self.room = room
        fetchRoomInfo()
        fetchRoomMessages() //メッセージを取得
    }
    
    //相手のアイコンやルーム名を取得
    func fetchRoomInfo() {
        Task {
            guard let partner = await fetchPartner() else { return }
            self.roomName = partner.userName
            if let iconURL = partner.photoURL {
                guard let partnerImageData = await FirebaseManager.shared.fetchImage(urlString: iconURL) else { return }
                self.roomIconData = partnerImageData
            }
        }
    }
    
    //2人の時に、相手のUser情報を取得
    func fetchPartner() async -> UserResponse? {
        if room.members.count == 2 {
            guard let currentUser = FirebaseManager.shared.currentUser else { return nil }
            guard let partnerID = room.members.first(where: { $0 != currentUser }) else { return nil }
            let partnerUserResponse = await FirebaseManager.shared.fetchUser(userId: partnerID)
            return partnerUserResponse
        }
        return nil
    }
    
    //ルーム内のメッセージを取得する
    func fetchRoomMessages() {
        guard let roomId = room.id else { return }
        Task {
            let messagesResult = await FirebaseManager.shared.fetchRoomMessages(roomID: roomId)
            self.messages = messagesResult
        }
    }
}
