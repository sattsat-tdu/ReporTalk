//
//  SettingsResource.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/25
//  
//

import SwiftUIFontIcon
import SwiftUI

//---- 設定項目の構築 -----
let settingResource = SettingSection(
    icon: .settings,
    title: "設定",
    items: [
        .section(accountSection),
        .navItem(NavItem(
            destination: AnyView(NotificationSettingView()),
            icon: .notifications,
            title: "通知")
        ),
        .section(notificationsSection),
        .section(designSection)
    ]
)

let accountSection = SettingSection(
    icon: .person,
    title: "アカウント",
    items: [
        .navItem(NavItem(
            destination: AnyView(FriendListView()),
            icon: .people_outline,
            title: "友達リスト")
        ),
        .navItem(NavItem(
            destination: AnyView(Text("パスワード変更View")),
            icon: .vpn_key,
            title: "パスワードを変更する")
        ),
        .buttonItem(ButtonItem(
            color: .red,
            title: "ログアウト",
            onClicked: {
                UIApplication.showModal(
                    modalItem: ModalItem(
                        type: .error,
                        title: "ログアウトしますか",
                        description: "ログアウトしても、メッセージの内容やアカウント情報は残ります。",
                        alignment: .bottom,
                        isCancelable: true,
                        onTapped: {
                            Task {
                                await FirebaseManager.shared.handleLogout()
                            }
                        }
                    )
                )
            })
        ),
        .navItem(NavItem(
            destination: AnyView(DeleteAccountView()),
            icon: .delete,
            title: "アカウント削除")
        )
])

let notificationsSection = SettingSection(
    icon: .notifications,
    title: "通知",
    items: [
        .toggleItem(ToggleItem(
            key: SettingKeys.notice.rawValue,
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
            key: SettingKeys.appearanceMode.rawValue,
            icon: .smartphone,
            title: "外観設定",
            options: [
                PickerOption(key: AppearanceMode.system.rawValue, value: "端末に合わせる"),
                PickerOption(key: AppearanceMode.light.rawValue, value: "ライトモード"),
                PickerOption(key: AppearanceMode.dark.rawValue, value: "ダークモード")
            ],
            defaultOption: AppearanceMode.system.rawValue,
            onChange: { result in
                guard let apperanceMode = AppearanceMode(rawValue: result) else {return}
                AppearanceManager.setAppearanceMode(apperanceMode)
            })
        )
])
