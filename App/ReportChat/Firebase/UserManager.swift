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

}
