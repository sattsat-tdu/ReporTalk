//
//  NotificationView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/15
//  
//

import SwiftUI
import SwiftUIFontIcon

struct NotificationView: View {
    
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var selectedUser: UserResponse?
    
    var body: some View {
        if let notifications = notificationManager.notifications {
            List(notifications) { notification in
                if let noticeType = notification.toNoticeType {
                    Button(action: {
                        fetchSenderUser(userId: notification.senderId)
                    }, label: {
                        HStack(alignment: .top, spacing: 16) {
                            FontIcon.text(
                                .materialIcon(code: noticeType.icon),
                                fontsize: 32)
                            
                            VStack(alignment: .leading) {
                                Text(notification.message)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                
                                Text(notification.timestamp.toString())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    })
                    .listRowBackground(Color.clear)
                    .sheet(item: $selectedUser) { user in
                        UserDetailView(user: user)
                    }
                }
            }
            .listStyle(.plain)
            .background(.tab)
            .navigationTitle("通知")
        } else {
            LoadingView(message: "通知を取得中")
        }
    }
    
    @MainActor
    private func fetchSenderUser(userId: String) {
        Task {
            let senderUserResult = await FirebaseManager.shared.fetchUser(userId: userId)
            switch senderUserResult {
            case .success(let user):
                self.selectedUser = user
            case .failure(let error):
                FirebaseError.shared.showErrorToast(error)
            }
        }
    }
}
#Preview {
    NotificationView()
        .environmentObject(NotificationManager())
}
