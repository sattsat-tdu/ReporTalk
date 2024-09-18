//
//  RoomCellViewModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/18
//  
//

import Foundation

@MainActor
final class RoomCellViewModel: ObservableObject {
    @Published var roomIconData: Data? = nil
    @Published var roomName: String = " --- "
    private let room: RoomResponse
    
    init(room: RoomResponse) {
        self.room = room
        fetchRoomInfo()
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
}
