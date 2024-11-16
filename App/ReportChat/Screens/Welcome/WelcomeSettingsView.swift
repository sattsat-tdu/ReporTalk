//
//  WelcomeSettingsView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/02
//  
//

import SwiftUI

struct WelcomeSettingsView: View {
    
    private enum WelcomeStep: Int, CaseIterable {
        case userIdSetting
        case userNameSetting
        case iconSetting
        case addFriends
        case finishSetting
        
        var nextStep: WelcomeStep? {
            if let nextStep = WelcomeStep(rawValue: self.rawValue + 1) {
                return nextStep
            } else {
                return nil
            }
        }
        
        var previousStep: WelcomeStep? {
            if let previousStep = WelcomeStep(rawValue: self.rawValue - 1) {
                return previousStep
            } else {
                return nil
            }
        }
        
        var title: String {
            switch self {
            case .userIdSetting:
                return "ユーザーIDを設定しましょう！"
            case .userNameSetting:
                return "ニックネームを教えてください！"
            case .iconSetting:
                return "アイコンを設定しましょう！"
            case .addFriends:
                return "友達を追加しよう！"
            case .finishSetting:
                return "それでは、始めましょう！"
            }
        }
        
        var description: String {
            switch self {
            case .userIdSetting:
                return "ユーザー検索・追加に使用します。\n（いつでも変更可能です）"
            case .userNameSetting:
                return "ここで設定した名前は公開されます。"
            case .iconSetting:
                return "スキップ可能です。"
            case .addFriends:
                return ""
            case .finishSetting:
                return "設定項目は、後から変更できます。 "
            }
        }
    }

    let totalSteps = Double(WelcomeStep.allCases.count - 1)
    @EnvironmentObject var viewModel: WelcomeViewModel
    @State private var welcomeStep: WelcomeStep = .userIdSetting
    var body: some View {
        VStack(spacing : 16) {
            ProgressView(value: Double(self.welcomeStep.rawValue), total: totalSteps)
                .tint(.buttonBack)
            
            Text(welcomeStep.title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            Text(welcomeStep.description)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            TabView(selection: $welcomeStep) {
                userIdSettingView
                    .tag(WelcomeStep.userIdSetting)
                userNameSettingView
                    .tag(WelcomeStep.userNameSetting)
                iconSettingView
                    .tag(WelcomeStep.iconSetting)
                addFriendsView
                    .tag(WelcomeStep.addFriends)
                finishSettingView
                    .tag(WelcomeStep.finishSetting)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            Spacer()
            
            HStack(spacing: 16) {
                BackButtonView(onClicked: {
                    if let previousStep = welcomeStep.previousStep {
                        self.welcomeStep = previousStep
                    } else {
                        UIApplication.showModal(modalItem: ModalItem(
                            type: .error,
                            title: "ログアウトしますか？",
                            alignment: .center,
                            isCancelable: true,
                            onTapped: {
                                Task {
                                    await FirebaseManager.shared.handleLogout()
                                }
                            }
                        ))
                    }
                })
                
                let buttonProperties: (style: CapsuleButton.ButtonType, text: String) = {
                    switch welcomeStep {
                    case .userIdSetting:
                        return (viewModel.handleState == .success ? .normal : .disable, "次へ")
                    case .userNameSetting:
                        return (viewModel.userName.isEmpty ? .disable : .normal, "次へ")
                    case .iconSetting:
                        return (.normal, "次へ（スキップ可能）")
                    case .addFriends:
                        return (.normal, "次へ（スキップ可能）")
                    case .finishSetting:
                        return (.normal, "始める")
                    }
                }()

                CapsuleButton(
                    style: buttonProperties.style,
                    text: buttonProperties.text,
                    onClicked: {
                        if let nextStep = welcomeStep.nextStep {
                            self.welcomeStep = nextStep
                        } else {
                            viewModel.addUserToFirestore()
                        }
                    }
                )
            }
            

        }
        .animation(.easeInOut, value: welcomeStep)
        .padding()
        .background(.mainBackground)
    }
    
    private var userIdSettingView: some View {
        VStack(alignment: .leading) {
            InputFormView(
                secureType: .normal,
                title:
                    """
                    - 6~20文字
                    - 英字（a~z）および数字（0~9）のみ
                    - 特殊文字は(_)と(.)のみ使用可能
                    ※ 数字のみの登録はできません。
                    """,
                placeholder: "user1234",
                text: $viewModel.handle
            )
            .keyboardType(.alphabet)
            
            HStack {
                viewModel.handleState.icon
                
                Text(viewModel.handleErrorMessage)
            }
            .hidden(viewModel.handle.isEmpty)
            .foregroundStyle(viewModel.handleState.color)
            
            Spacer()
        }
    }
    
    private var userNameSettingView: some View {
        InputFormView(
            secureType: .normal,
            title: "ユーザーネーム",
            placeholder: "ダンダイ",
            text: $viewModel.userName
        )
    }
    
    private var iconSettingView: some View {
        VStack {
            Text("アイコン設定(任意)")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16){
                PhotoPickerView(selectedImageData: $viewModel.imageData)
                
                Text("アイコンタップで画像\((viewModel.imageData != nil) ? "変更" : "追加")")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var addFriendsView: some View {
        Text("友達追加画面")
    }
    
    private var finishSettingView: some View {
        VStack {
            Text("プロフィールのような見た目のViewにする")
                .font(.footnote)
            
            Text(viewModel.userName)
                .font(.headline)
            
            if let imageData = viewModel.imageData,
            let image = UIImage(data: imageData) {
                Image(uiImage: image)
            }
        }
    }
}

#Preview {
    WelcomeSettingsView()
        .environmentObject(WelcomeViewModel(router: Router()))
}
