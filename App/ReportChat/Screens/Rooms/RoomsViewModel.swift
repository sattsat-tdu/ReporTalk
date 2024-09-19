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
    private let user: UserResponse
    
    init(user: UserResponse) {
        self.user = user
        self.fetchRooms(roomIDs: user.rooms)
    }
    
    func fetchRooms(roomIDs: [String]) {
        var rooms: [RoomResponse] = []
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
