//
//  RoomCache.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/22
//  
//

import Foundation

final class RoomsCache {
    static let shared = RoomsCache()
    private let cache = NSCache<NSString, RoomViewModel>() // RoomViewModelをキャッシュ

    private init() {
        cache.countLimit = 5
    }

    // キャッシュからRoomViewModelを取得
    func getRoomViewModel(forKey key: String) -> RoomViewModel? {
        return cache.object(forKey: key as NSString)
    }

    // キャッシュにRoomViewModelを保存
    func setRoomViewModel(_ viewModel: RoomViewModel, forKey key: String) {
        print("ルームをキャッシュに保存")
        cache.setObject(viewModel, forKey: key as NSString)
    }
}
