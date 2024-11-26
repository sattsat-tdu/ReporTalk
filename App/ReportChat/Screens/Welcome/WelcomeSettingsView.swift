//
//  WelcomeSettingsView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/10/02
//  
//

import SwiftUI
import SwiftUIFontIcon

struct WelcomeSettingsView: View {
    
    private enum WelcomeStep: Int, CaseIterable {
        case userIdSetting
        case userNameSetting
        case iconSetting
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
                return "友達があなたを見つけやすくなります。"
            case .finishSetting:
                return "設定項目は、後から変更できます。 "
            }
        }
    }
    
    let totalSteps = Double(WelcomeStep.allCases.count - 1)
    @EnvironmentObject var viewModel: WelcomeViewModel
    @State private var welcomeStep: WelcomeStep = .userIdSetting
    @State private var photoPickerFlg = false
    @FocusState private var isKeyboardFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            ProgressView(value: Double(self.welcomeStep.rawValue), total: totalSteps)
                .tint(.buttonBackground)
            
            Text(welcomeStep.title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            Text(welcomeStep.description)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .hidden(isKeyboardFocused)
            
            Spacer().frame(maxHeight: 50)
                .hidden(isKeyboardFocused)
            
            Group {
                switch welcomeStep {
                case .userIdSetting:
                    userIdSettingView
                case .userNameSetting:
                    userNameSettingView
                case .iconSetting:
                    iconSettingView
                case .finishSetting:
                    finishSettingView
                }
            }
            
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
                    case .finishSetting:
                        return (.normal, "始める")
                    }
                }()

                CapsuleButton(
                    style: buttonProperties.style,
                    text: buttonProperties.text,
                    onClicked: {
                        isKeyboardFocused = false
                        if let nextStep = welcomeStep.nextStep {
                            self.welcomeStep = nextStep
                        } else {
                            viewModel.addUserToFirestore()
                        }
                    }
                )
                .disabled(!isNextButtonEnabled()) // 「次へ」ボタンの有効/無効化
            }
        }
        .animation(.easeInOut, value: welcomeStep)
        .padding()
        .background(.mainBackground)
        .sheet(isPresented: $photoPickerFlg) {
            PhotoPickerView(imageData: $viewModel.imageData)
                .ignoresSafeArea()
        }
    }
    
    private var userIdSettingView: some View {
        VStack(alignment: .leading) {
            InputFormView(
                secureType: .normal,
                keyboardType: .alphabet,
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
            .focused($isKeyboardFocused)
            
            HStack {
                viewModel.handleState.icon
                
                Text(viewModel.handleErrorMessage)
            }
            .hidden(viewModel.handle.isEmpty)
            .foregroundStyle(viewModel.handleState.color)
        }
    }
    
    private var userNameSettingView: some View {
        InputFormView(
            secureType: .normal,
            keyboardType: .default,
            title: "ユーザーネーム",
            placeholder: "ダンダイ",
            text: $viewModel.userName
        )
        .focused($isKeyboardFocused)
        
    }
    
    private var iconSettingView: some View {
        VStack(spacing: 24) {
            
            let iconSize: CGFloat = 160
            
            Button(action: {
                photoPickerFlg.toggle()
            }, label: {
                if let imageData = viewModel.imageData,
                   let uiImage = UIImage(data: imageData){
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(height: iconSize)
                        .shadow(radius: 3)
                } else {
                    FontIcon.text(.materialIcon(code: .account_circle),
                                  fontsize: iconSize)
                }
            })
            
            Text("アイコンタップで画像\((viewModel.imageData != nil) ? "変更" : "選択")")
                .font(.headline)
        }
        .foregroundStyle(.secondary)
    }
    
    private var finishSettingView: some View {
        VStack(alignment: .leading) {
            Text("以下の内容で初期登録を行います")
                .font(.headline)
            
            VStack(spacing: 24) {
                if let imageData = viewModel.imageData,
                   let uiImage = UIImage(data: imageData){
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(height: 140)
                        .shadow(radius: 3)
                } else {
                    FontIcon.text(.materialIcon(code: .account_circle),
                                  fontsize: 140)
                }
                
                VStack {
                    Text("@\(viewModel.handle)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text(viewModel.userName)
                        .font(.title.bold())
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .itemStyle()
            
            Text("↓戻って編集する")
                .foregroundStyle(.secondary)
        }
    }
    
    // 次へボタンが有効かどうかを判定するメソッド
    private func isNextButtonEnabled() -> Bool {
        switch welcomeStep {
        case .userIdSetting:
            return viewModel.handleState == .success
        case .userNameSetting:
            return !viewModel.userName.isEmpty
        default:
            return true
        }
    }
}

#Preview {
    WelcomeSettingsView()
        .environmentObject(WelcomeViewModel(router: Router()))
}
