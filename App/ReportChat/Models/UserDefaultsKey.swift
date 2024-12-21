//
//  UserDefaultsKey.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/12/21
//  
//


// MARK: - 共通プロトコル
protocol UserDefaultsKey {
    var rawValue: String { get }
}

// MARK: - Keysの定義
enum SettingKeys: String, UserDefaultsKey {
    case notice //通知ON・OFF
    case appearanceMode //外観モード
}

enum AppStateKeys: String, UserDefaultsKey {
    case fcmToken
}
