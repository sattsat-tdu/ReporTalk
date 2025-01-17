//
//  SettingModel.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/25
//  
//

import SwiftUI
import SwiftUIFontIcon

// 設定項目の種類を定義
enum SettingsItem {
    case section(SettingSection)
    case navItem(NavItem)
    case buttonItem(ButtonItem)
    case toggleItem(ToggleItem)
    case safariItem(SafariItem)
    case pickerItem(PickerItem)
}

struct SettingSection {
    let icon: MaterialIconCode?
    let title: String
    let items: [SettingsItem]
    
    init(icon: MaterialIconCode? = nil, title: String, items: [SettingsItem]) {
        self.icon = icon
        self.title = title
        self.items = items
    }
}

struct NavItem {
    let destination: AnyView
    let icon: MaterialIconCode?
    let title: String
    let description: String?
    
    init(
        destination: AnyView,
        icon: MaterialIconCode? = nil,
        title: String,
        description: String? = nil
    ) {
        self.destination = destination
        self.icon = icon
        self.title = title
        self.description = description
    }
}

struct ButtonItem {
    let icon: MaterialIconCode?
    let color: Color?
    let title: String
    let description: String?
    let onClicked: () -> Void // 引数なしのクロージャー
    
    init(
        icon: MaterialIconCode? = nil,
        color: Color? = nil,
        title: String,
        description: String? = nil,
        onClicked: @escaping () -> Void
    ) {
        self.icon = icon
        self.color = color
        self.title = title
        self.description = description
        self.onClicked = onClicked
    }
}

struct ToggleItem {
    let key: UserDefaultsKey
    let title: String
    let icon: MaterialIconCode?
    let description: String?
    
    init(
        key: UserDefaultsKey,
        title: String,
        icon: MaterialIconCode? = nil,
        description: String? = nil
    ) {
        self.key = key
        self.title = title
        self.icon = icon
        self.description = description
    }
}

struct SafariItem {
    let title: String
    let icon: MaterialIconCode?
    let url: String
}

struct PickerItem {
    let key: UserDefaultsKey
    let icon: MaterialIconCode?
    let title: String
    let description: String?
    let options: [PickerOption]
    let defaultOption: String
    let onChange: ((String) -> Void)?

    init(
        key: UserDefaultsKey,
        icon: MaterialIconCode? = nil,
        title: String,
        description: String? = nil,
        options: [PickerOption],
        defaultOption: String,
        onChange: ((String)-> Void)? = nil
    ) {
        self.key = key
        self.icon = icon
        self.title = title
        self.description = description
        self.options = options
        self.defaultOption = defaultOption
        self.onChange = onChange
    }
}

struct PickerOption {
    let key: String
    let value: String
}
