//
//  SettingsResource.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/25
//  
//

import SwiftUIFontIcon
import SwiftUI

let settingResource = SettingSection(
    icon: .settings,
    title: "設定",
    items: [
        .section(notificationsSection),
        .section(designSection)
    ]
)

let notificationsSection = SettingSection(
    icon: .notifications,
    title: "通知",
    items: [
        .toggleItem(ToggleItem(
            key: "notice",
            title: "通知",
            icon: .notifications_active,
            description: "通知をOFFにすると、友達からの報告が気付きにくくなってしまいます")
        ),
        .navItem(NavItem(
            destination: AnyView(Text("通知サウンド設定")),
            title: "通知サウンド")
        )
])

let designSection = SettingSection(
    icon: .color_lens,
    title: "デザイン",
    items: [
        .pickerItem(PickerItem(
            key: "design",
            icon: .smartphone,
            title: "外観設定",
            options: [
                PickerOption(key: "system", value: "端末に合わせる"),
                PickerOption(key: "light", value: "ライトモード"),
                PickerOption(key: "dark", value: "ダークモード")
            ],
            defaultOption: "system",
            onChange: { result in
                print(result) //外観を変える処理を記載する
            })
        )
])
