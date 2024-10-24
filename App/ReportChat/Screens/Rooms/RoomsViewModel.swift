//
//  RoomsViewModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import Foundation
import FirebaseFirestore

@MainActor
final class RoomsViewModel: ObservableObject {
    @Published var roomsModel: [RoomViewModel]? = nil
    private let appManager = AppManager.shared
    private let firestore = Firestore.firestore()
    private var listener: ListenerRegistration?
    //試作
    @Published var rooms: [RoomResponse]? = nil
    
    init() {
        self.listenToRoomUpdates()
    }
    
    deinit {
        listener?.remove()
        print("ルームリスナーの監視が解除されました")
    }
    
    //ルームのリアルタイム監視
    private func listenToRoomUpdates(limit: Int = 20) {
        guard let loginUserId = AppManager.shared.currentUser?.id else { return }
        let query = firestore.collection("rooms")
            .whereField("members", arrayContains: loginUserId)
            .order(by: "lastUpdated", descending: true)
            .limit(to: limit)
        
        listener = query.addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("ルームの更新に失敗しました: \(error)")
                return
            }

            guard let documents = snapshot?.documents else { return }

            let newRooms = documents.compactMap { document in
                try? document.data(as: RoomResponse.self)
            }
            
            self?.rooms = newRooms
        }
    }
    
    //RoomResponseを引数にしたRoomViewModelのキャッシュ
    func cacheRoomViewModel(for room: RoomResponse) -> RoomViewModel? {
        guard let roomId = room.id else {
            fatalError("Room IDの取得に失敗")
        }
        if let cachedViewModel = RoomsCache.shared.getRoomViewModel(forKey: roomId) {
            return cachedViewModel
        } else {
            let newViewModel = RoomViewModel(room: room)
            RoomsCache.shared.setRoomViewModel(newViewModel, forKey: roomId)
            return newViewModel
        }
    }
}
