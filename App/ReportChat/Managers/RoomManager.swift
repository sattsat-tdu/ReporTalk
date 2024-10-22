//
//  RoomManager.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/22
//  
//

import FirebaseFirestore

final class RoomManager {
    static let shared = RoomManager()
    private let firestore = Firestore.firestore()
    
    private init() {}
    
    //idからルーム情報を取得
    func fetchRoom(roomID: String) async -> RoomResponse? {
        do {
            let snapshot = try await firestore
                .collection("rooms")
                .document(roomID)
                .getDocument()
            
            return try snapshot.data(as: RoomResponse.self)
        } catch _ as NSError {
            print("ルームが見つかりませんでした。")
            return nil
        }
    }
    
    // プライベートなルームの作成・存在していればfetchする
    func fetchPrivateRoom(partnerId: String) async -> RoomResponse? {
        guard let loginUser = AppManager.shared.currentUser,
              let loginUserId = loginUser.id else { return nil }
        
        let sortedUIDs = [loginUserId, partnerId].sorted()
        let roomId = "\(sortedUIDs[0])_\(sortedUIDs[1])"
        
        do {
            // ルームが存在するかチェック
            let snapshot = try await firestore
                .collection("rooms")
                .document(roomId)
                .getDocument()
            
            if snapshot.exists {
                // ルームが見つかった場合はそのルームを返す
                return try snapshot.data(as: RoomResponse.self)
            } else {
                // ルームが存在しない場合、新しいルームを作成する
                let newRoom = RoomResponse(
                    id: roomId, // ルームIDを設定
                    members: [loginUserId, partnerId],
                    roomIcon: nil,
                    roomName: nil
                )

                try await firestore
                    .collection("rooms")
                    .document(roomId)
                    .setData(newRoom.toDictionary())
                
                print("新しいルームを作成しました: \(roomId)")
                
                return newRoom
            }
            
        } catch {
            print("ルームの作成に失敗しました(RoomManager): \(error.localizedDescription)")
            return nil
        }
    }
}
