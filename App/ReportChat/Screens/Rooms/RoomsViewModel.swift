//
//  RoomsViewModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/16
//  
//

import Foundation

@MainActor
final class RoomsViewModel: ObservableObject {
    @Published var rooms: [RoomResponse]? = nil
    private var roomCellViewModels: [String: RoomViewModel] = [:] // RoomごとのViewModelをキャッシュ
    private let appManager = AppManager.shared
    
    init() {
        self.fetchRooms()
        print("RoomsViewのinitが呼ばれました")
    }
    
    func fetchRooms() {
        var rooms: [RoomResponse] = []
        guard let currentUser = appManager.currentUser else { return }
        let roomIDs = currentUser.rooms
        
        if roomIDs.isEmpty {
            self.rooms = []
            print("ユーザーのルームが一つも存在しません。")
            return
        }
        
        Task {
            for roomID in roomIDs {
                let roomResult = await FirebaseManager.shared.fetchRoom(roomID: roomID)
                if let room = roomResult {
                    rooms.append(room)
                }
            }
            self.rooms = rooms
        }
    }
    
    //キャッシュの仕組みを使用する。これにより再ロードを防ぐ
    func cellViewModel(for room: RoomResponse) -> RoomViewModel {
        guard let roomId = room.id else {
            print("Room IDがnilです。")
            return RoomViewModel(room: room)
        }
        if let viewModel = roomCellViewModels[roomId] {
            return viewModel
        } else {
            let newViewModel = RoomViewModel(room: room)
            roomCellViewModels[roomId] = newViewModel
            return newViewModel
        }
    }
}
