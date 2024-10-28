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
    @Published var roomsModel: [RoomViewModel] = []
    private let appManager = AppManager.shared
    private let firestore = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let cache = RoomsCache.shared
    
    init() {
        self.listenToRoomUpdates()
    }
    
    deinit {
        listener?.remove()
        print("ルームリスナーの監視が解除されました")
    }
    
    // ルームのリアルタイム監視
    private func listenToRoomUpdates(limit: Int = 20) {
        guard let loginUserId = AppManager.shared.currentUser?.id else { return }
        let query = firestore.collection("rooms")
            .whereField("members", arrayContains: loginUserId)
            .order(by: "lastUpdated", descending: true)
            .limit(to: limit)
        
        listener?.remove()
        listener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            guard let documents = snapshot?.documents else {
                print("fetch Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Firestoreの順序に従ってupdatedRoomsを再構築
            var updatedRooms: [RoomViewModel] = []
            
            documents.forEach { document in
                do {
                    let room = try document.data(as: RoomResponse.self)
                    // 既存のRoomViewModelを検索
                    if let existingViewModel = self.roomsModel.first(where: { $0.room.id == room.id }) {
                        // 既存のRoomViewModelがある場合は更新のみ
                        existingViewModel.updateRoom(with: room)
                        updatedRooms.append(existingViewModel)
                        print("更新されました: \(room.id!)")
                    } else {
                        // 新規作成の場合
                        let newViewModel = RoomViewModel(room: room)
                        updatedRooms.append(newViewModel)
                        print("新規作成されました: \(room.id!)")
                    }
                } catch {
                    print("Room Decode Error: \(error.localizedDescription)")
                }
            }
            
            // メインスレッドでroomsModelを更新
            DispatchQueue.main.async {
                self.roomsModel = updatedRooms
            }
        }
    }
    
    // キャッシュに基づいてRoomViewModelを取得または作成
//    private func cacheOrCreateRoomViewModel(for room: RoomResponse) -> RoomViewModel {
//        guard let roomId = room.id else {
//            fatalError("Room IDの取得に失敗")
//        }
//        // キャッシュから取得
//        if let cachedViewModel = cache.getRoomViewModel(forKey: roomId) {
//            return cachedViewModel
//        } else {
//            let newViewModel = RoomViewModel(room: room)
//            cache.setRoomViewModel(newViewModel, forKey: roomId)
//            return newViewModel
//        }
//    }
}
