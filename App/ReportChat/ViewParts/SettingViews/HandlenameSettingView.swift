//
//  HandlenameSettingView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/11/26
//  
//

import SwiftUI
import SwiftUIFontIcon

struct HandlenameSettingView: View {
    
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    
    private let currentHandle: String
    @StateObject private var viewModel: HandleSettingViewModel
    private let onHandleChange: (String) -> Void
    
    init(currentHandle: String, onHandleChange: @escaping (String) -> Void) {
        self.currentHandle = currentHandle
        self.onHandleChange = onHandleChange
        _viewModel = StateObject(
            wrappedValue: HandleSettingViewModel(currentHandle: currentHandle))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            Text("現在のユーザーID")
                .foregroundStyle(.secondary)
            
            Text(currentHandle)
                .foregroundStyle(.primary)
                .font(.headline)
            
            Divider()
            
            InputFormView(
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
            .focused($isFocused)
            
            HStack {
                viewModel.handleState.icon
                Text(viewModel.handleErrorMessage)
            }
            .hidden(viewModel.isHiddenMessage())
            .foregroundStyle(viewModel.handleState.color)
            
            Spacer()
        }
        .padding()
        .frame(maxHeight: .infinity)
        .background(.mainBackground)
        .onAppear {
            isFocused = true
        }
        .navigationTitle("ハンドルネーム設定")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    onHandleChange(viewModel.handle)
                    dismiss()
                }, label: {
                    Text("更新")
                })
                .disabled(!(viewModel.handleState == .success))
            }
        }
    }
}

#Preview {
    HandlenameSettingView(currentHandle: "user123", onHandleChange: {_ in 
        
    })
}

enum HandleState {
    case loading
    case success
    case error
    
    var icon: Text {
        switch self {
        case .loading:
            FontIcon.text(.materialIcon(code: .data_usage))
        case .success:
            FontIcon.text(.materialIcon(code: .check_circle))
        case .error:
            FontIcon.text(.materialIcon(code: .error))
        }
    }
    
    var color: Color {
        switch self {
        case .loading:
            return .secondary
        case .success:
            return .green
        case .error:
            return .red
        }
    }
}

import Foundation
import Combine

@MainActor
final class HandleSettingViewModel: ObservableObject {
    
    let currentHandle: String
    @Published var handle: String
    @Published var handleState: HandleState = .loading
    @Published var handleErrorMessage = ""
    
    private var handleNameObserver: AnyCancellable?
    
    init(currentHandle: String) {
        print("初期化されました")
        self.currentHandle = currentHandle
        _handle = Published(initialValue: currentHandle)
        //ハンドルネームの監視
        handleNameObserver = $handle
            .debounce(for: .milliseconds(100), scheduler: RunLoop.main)
            .removeDuplicates() // 重複する入力値は無視
            .sink(receiveValue: validateHandle)
    }
    
    
    @MainActor
    private func validateHandle(for newHandle: String){
        
        handleState = .loading
        handleErrorMessage = ""
        
        if newHandle == currentHandle || newHandle.isEmpty { return }
        
        //構文チェック
        let validationResult = HandleChecker.validate(handleName: newHandle)
        if case .failure(let validationError) = validationResult {
            self.setError(validationError)
            return
        }
        
        //重複チェック
        Task {
            let duplicateResult = await HandleChecker.checkAvailability(handleName: newHandle)
            switch duplicateResult {
            case .success:
                handleState = .success
                handleErrorMessage = "唯一無二のユーザーIDです！"
            case .failure(let error):
                self.setError(error)
            }
        }
    }
    
    func isHiddenMessage() -> Bool {
        handle == currentHandle || handle.isEmpty
    }
    
    // エラーメッセージを設定するメソッド
    private func setError(_ error: HandleNameError) {
        self.handleState = .error
        self.handleErrorMessage = error.rawValue
    }
}
