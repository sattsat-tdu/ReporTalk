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
        case handlename
        case statusMessage
    }
    
    //キーボードを閉じる
    var gesture: some Gesture {
        DragGesture()
            .onChanged{ value in
                if value.translation.height != 0 {
                    self.focusedField = nil
                }
            }
    }
    
    @Environment(\.dismiss) var dismiss
    @State private var isEditImage = false
    @State private var isEditStatus = false
    @FocusState  private var focusedField: Field?
    
    @State private var handle: String
    @State private var username: String
    @State private var statusMessage: String
    private var iconUrl: String?
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
        self.iconUrl = user.photoURL
        self.originalUserName = user.userName
        self.originalHandleName = user.handle
        self.originalStatusMessage = user.statusMessage
    }
    
    var body: some View {
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
            guard let iconUrl = self.iconUrl else { return }
            imageData = await fetchData(from: iconUrl)
        }
    }
    
    private var headerView: some View {
        
        HStack {
            FontIcon.button(.materialIcon(code: .close), action: {
                dismiss()
            }, fontsize: 28)
            .padding(12)
            .background(.item)
            .clipShape(Circle())
            
            Text("プロフィール編集")
                .font(.headline)
                .frame(maxWidth: .infinity)
            
            Button(action: {
                if isEditImage {
                    print("画像を更新")
                }
                if isModified {
                    print("ステータスを更新")
                }
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
                if let imageData,
                   let uiImage = UIImage(data: imageData){
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(height: iconSize)
                        .shadow(radius: 3)
                } else if (iconUrl != nil) {
                    LoadingBackgroundView()
                        .frame(width: iconSize, height: iconSize)
                        .background(.item)
                        .clipShape(Circle())
                } else {
                    FontIcon.text(.materialIcon(code: .image),
                                  fontsize: 56)
                    .padding()
                    .frame(width: iconSize, height: iconSize)
                    .background(.item)
                    .clipShape(Circle())
                }
            })
            .onChange(of: imageData) { oldValue, newValue in
                if oldValue != nil || iconUrl == nil {
                    isEditImage = true
                }
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
            
            InputFormView(
                keyboardType: .alphabet,
                title: "ハンドルネーム",
                placeholder: "ハンドルネームを入力する",
                text: $handle)
            .focused($focusedField, equals: .handlename)
            
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
            .background(.fieldBack)
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
}

#Preview {
    EditUserProfileView()
}
