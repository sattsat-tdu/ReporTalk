//
//  NotificationSettingView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/12/21
//  
//

import SwiftUI

struct NotificationSettingView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    private let notificationManager = NotificationManager.shared
    @State private var isAuthorized = false

    var body: some View {
        List {
            Group {
                if isAuthorized {
                    ToggleCell(
                        toggleItem: ToggleItem(
                            key: SettingKeys.notice.rawValue,
                            title: "通知",
                            icon: .notifications_active,
                            description: "通知をOFFにすると、友達からの報告が気付きにくくなってしまいます"
                        )
                    )
                    
                    CustomNavCell(
                        navItem: NavItem(
                            destination: AnyView(Text("通知サウンド設定")),
                            title: "通知サウンド"
                        )
                    )
                } else {
                    ButtonCell(buttonItem: ButtonItem(
                        icon: .call_missed_outgoing,
                        title: "プッシュ通知を許可する必要があります",
                        description: "iPhoneの設定画面を開きます",
                        onClicked: {
                            openNotificationSettings()
                        }))
                }
            }
            .padding(.vertical, 4)
            .frame(minHeight: 38)
            .listRowBackground(Color.item)
        }
        .onChange(of: scenePhase) {
            //アプリに戻った時にも検知
            if scenePhase == .active {
                checkNotificationState()
            }
        }
        .onAppear {
            checkNotificationState(registerForNotifications: false)
        }
        .scrollContentBackground(.hidden)
        .background(.mainBackground)
        .listRowSpacing(10)
        .navigationTitle("通知設定")
    }
    
    //通知認証状態を取得
    private func checkNotificationState(registerForNotifications: Bool = true) {
        Task {
            let authState = await notificationManager.getNotificationAuth()
            isAuthorized = authState != .denied
            // 通知が許可されており、かつ登録処理を許可した場合のみ通知登録
            if authState == .authorized && registerForNotifications {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    //設定が拒否された場合に開くView
    private func openNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

#Preview {
    NotificationSettingView()
}
