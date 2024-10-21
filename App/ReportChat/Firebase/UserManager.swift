//
//  UserManager.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/11
//  
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class UserManager: ObservableObject {
    //シングルトン
    static let shared = UserManager()
    
    private var userCache: UserResponse? = nil
    let auth: Auth
    let storage: Storage
    let fireStore: Firestore
    
    init() {
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.fireStore = Firestore.firestore()
    }
    
    func addRoom(roomId: String) async -> Result<Void, AddIdError> {
        do {
            guard let loginUser = AppManager.shared.currentUser else { return .failure(.userNotFound) }
            
            guard let uid = loginUser.id else { return .failure(.userNotFound) }
            var updatedRooms: [String] = loginUser.friends

            if !updatedRooms.contains(roomId) {
                updatedRooms.append(roomId)
                
                try await self.fireStore
                    .collection("users")
                    .document(uid)
                    .updateData(["rooms": updatedRooms])
                
                print("ルームが追加されました: \(roomId)")
                return .success(())
            } else {
                return .failure(.alreadyExists)
            }
        } catch {
            return .failure(.unknownError)
        }
    }
}
