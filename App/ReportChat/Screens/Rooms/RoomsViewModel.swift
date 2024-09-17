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
    @Published var rooms: [RoomResponse]?
    
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
}
