//
//  EditUserProfileView.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/11/23
//
//

import SwiftUI
import SwiftUIFontIcon

struct EditUserProfileView: View {
    
    private enum Field: Hashable {
        case username
        case statusMessage
    }
    
    @Environment(\.dismiss) var dismiss
    @State private var isEditImage = false
    @FocusState  private var focusedField: Field?
    
    @State private var handle: String
    @State private var username: String
    @State private var statusMessage: String
    @State private var photoURL: String?
    private let iconSize: CGFloat = 120
    @State private var imageData: Data?
    @State private var photoPickerFlg = false
    //変更検知のため
    private let originalUserName: String
    private let originalHandleName: String
    private let originalStatusMessage: String
    
    
    init?() {
        guard let user = AppManager.shared.currentUser else { return nil }
        _username = State(initialValue: user.userName)
        _statusMessage = State(initialValue: user.statusMessage)
        _handle = State(initialValue: user.handle)
        _photoURL = State(initialValue: user.photoURL)
        self.originalUserName = user.userName
        self.originalHandleName = user.handle
        self.originalStatusMessage = user.statusMessage
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    headerView
                    
                    VStack(spacing: 24) {
                        selectIconView
                        
                        Divider()
                        
                        inputView
                    }
                    .padding()
                    .itemStyle()
                }
                .padding()
            }
            .onTapGesture {
                focusedField = nil
            }
            .contentMargins(.bottom, 24)
            .background(.mainBackground)
            .sheet(isPresented: $photoPickerFlg) {
                PhotoPickerView(imageData: $imageData)
                    .ignoresSafeArea()
            }
            .task {
                guard let iconUrl = self.photoURL else { return }
                imageData = await fetchData(from: iconUrl)
            }
        }
    }
    
    private var headerView: some View {
        
        HStack {
            FontIcon.button(.materialIcon(code: .close), action: {
                if isEditImage || isModified {
                    UIApplication.showModal(modalItem: ModalItem(
                        type: .info,
                        title: "変更を破棄しますか？",
                        description: "変更を保存する場合は、保存をタップしてください。",
                        alignment: .center,
                        isCancelable: true,
                        onTapped: {
                            dismiss()
                        }))
                } else {
                    dismiss()
                }
            }, fontsize: 28)
            .padding(12)
            .background(.item)
            .clipShape(Circle())
            
            Text("プロフィール編集")
                .font(.headline)
                .frame(maxWidth: .infinity)
            
            Button(action: {
                saveUserStatus()
                dismiss()
            }, label: {
                Text("保存")
                    .fontWeight(.semibold)
                    .foregroundStyle(isEditImage || isModified ?
                        .appAccent : .secondary)
            })
        }
    }
    
    private var selectIconView: some View {
        VStack {
            Text("アイコン画像")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {
                photoPickerFlg.toggle()
            }, label: {
                Group {
                    if let imageData,
                       let uiImage = UIImage(data: imageData){
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    } else if (self.photoURL != nil) {
                        LoadingBackgroundView()
                    } else {
                        FontIcon.text(.materialIcon(code: .image),
                                      fontsize: 48)
                    }
                }
                .frame(width: iconSize, height: iconSize)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.buttonBackground, lineWidth: 2)
                )
            })
            .onChange(of: imageData) { oldValue, newValue in
                if oldValue != nil || self.photoURL == nil {
                    isEditImage = true
                }
            }
            .overlay(alignment: .topTrailing) {
                FontIcon.button(.materialIcon(code: .delete_forever),
                                action: {
                    self.photoURL = nil
                    imageData = nil
                })
                .padding(8)
                .foregroundStyle(.red)
                .background(.item)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.buttonBackground, lineWidth: 2)
                )
                .hidden(imageData == nil)
            }
        }
    }
    
    private var inputView: some View {
        VStack(spacing: 24) {
            InputFormView(
                keyboardType: .default,
                title: "名前",
                placeholder: "名前を入力する",
                text: $username)
            .focused($focusedField, equals: .username)
            
            Text("ユーザーID")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            NavigationLink(
                destination: HandlenameSettingView(
                    currentHandle: originalHandleName,
                    onHandleChange: { newHandle in
                        handle = newHandle
                    }),
                label: {
                    HStack {
                        Text(handle).foregroundStyle(.primary)
                        Spacer()
                        Text("〉").foregroundStyle(.secondary)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.secondary, lineWidth: 2)
                    )
                })
            
            Text("ステータスメッセージ")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField(
                "みんなにひとこと",
                text: $statusMessage,
                axis: .vertical
            )
            .frame(maxHeight: 248)
            .padding(12)
            .background(.fieldBackground)
            .clipShape(.rect(cornerRadius: 8))
            .textFieldStyle(.plain)
            .focused($focusedField, equals: .statusMessage)
        }
    }
    
    // 保存ボタンを有効にする条件
    private var isModified: Bool {
        username != originalUserName ||
        statusMessage != originalStatusMessage ||
        handle != originalHandleName
    }
    
    
    //URLからdata型に変換
    func fetchData(from urlString: String) async -> Data? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            return nil
        }
    }
    
    private func saveUserStatus() {
        guard let user = AppManager.shared.currentUser else { return }
        guard let uid = user.id else { return }
        let service = UserServiceManager.shared
        UIApplication.showLoading(message: "更新中")
        Task {
            //画像の変更検知
            if isEditImage {
                if let imageData {
                    let imageResult = await service.uploadUserIcon(
                        userId: uid,
                        imageData: imageData
                    )
                    switch imageResult {
                    case .success(let imageUrl):
                        await service.updateUserIcon(imageUrl: imageUrl)
                        UIApplication.showToast(
                            type: .success,
                            message: "画像を更新しました！")
                    case .failure(let error):
                        FirebaseError.shared.showErrorToast(error)
                    }
                } else { //imageDataが存在しないため、フィールド削除処理
                    let deleteUserIconResult = await service.deleteUserIcon(userId: uid)
                    switch deleteUserIconResult {
                    case .success(_):
                        await service.updateUserIcon(imageUrl: nil)
                        UIApplication.showToast(
                            type: .success,
                            message: "画像を削除しました！")
                    case .failure(let error):
                        FirebaseError.shared.showErrorToast(error)
                    }
                }
            }
            
            //各ステータスの変更検知
            if isModified {
                let updateUser = UserResponse(
                    id: user.id,
                    handle: self.handle,
                    userName: self.username,
                    email: user.email,
                    statusMessage: self.statusMessage,
                    friends: user.friends,
                    photoURL: nil,
                    rooms: user.rooms
                )
                let updateResult = await service.saveUser(user: updateUser)
                switch updateResult {
                case .success(_):
                    UIApplication.showToast(
                        type: .success,
                        message: "ユーザー情報を更新しました！")
                case .failure(let error):
                    FirebaseError.shared.showErrorToast(error)
                }
            }
            UIApplication.hideLoading()
        }
    }
    
    //FireStorageに画像をアップロード
    func uploadUserIcon(uid: String) async -> String? {
        guard let imageData = self.imageData else { return nil }
        let imageResult = await UserServiceManager.shared.uploadUserIcon(userId: uid, imageData: imageData)
        switch imageResult {
        case .success(let imageUrl):
            return imageUrl
        case .failure(let uploadError):
            UIApplication.showToast(type: .error, message: uploadError.localizedDescription)
            return nil
        }
    }
}

#Preview {
    EditUserProfileView()
}
