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
    @State private var welcomeStep: WelcomeStep = .userNameSetting
    var body: some View {
        VStack(spacing : 16) {
            ProgressView(value: Double(self.welcomeStep.rawValue), total: totalSteps)
                .tint(.buttonBack)
            
            Text(welcomeStep.title)
                .font(.largeTitle.bold())
            
            Text(welcomeStep.description)
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            TabView(selection: $welcomeStep) {
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
                    }
                })
                
                if welcomeStep == .finishSetting {
                    CapsuleButton(style: .primary, text: "始める",onClicked: {
                        viewModel.addUserToFirestore()
                        viewModel.welcomeSettingsFlg.toggle()
                    })
                } else {
                    CapsuleButton(style: viewModel.userName.isEmpty ? .disable : .primary, text: "次へ",onClicked: {
                        if let nextStep = welcomeStep.nextStep {
                            self.welcomeStep = nextStep
                        }
                    })
                }
            }
            

        }
        .animation(.easeInOut, value: welcomeStep)
        .padding()
        .background(.tab)
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
