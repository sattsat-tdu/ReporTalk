//
//  AppearanceModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/11/19
//  
//

import UIKit

enum AppearanceMode: String {
    case system
    case dark
    case light
}

final class AppearanceManager {
    static func loadApperanceMode() -> AppearanceMode {
        guard let rawValue = UserDefaults.standard.string(forKey: SettingKeys.appearanceMode.rawValue) else {
            return .system
        }
        return AppearanceMode(rawValue: rawValue) ?? .system
    }
    
    static func setAppearanceMode(_ mode: AppearanceMode) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        switch mode {
        case .system:
            window?.overrideUserInterfaceStyle = .unspecified
        case .dark:
            window?.overrideUserInterfaceStyle = .dark
        case .light:
            window?.overrideUserInterfaceStyle = .light
        }
    }
}
