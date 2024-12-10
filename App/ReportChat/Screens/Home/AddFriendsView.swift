//
//  AddFriendsView.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/10/13
//
//

import SwiftUI
import SwiftUIFontIcon

struct AddFriendsView: View {

    @StateObject private var viewModel = AddFriendsViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.isPresented) private var isPresented
    @State private var isModal = false
    @FocusState var isFocused: Bool
    @State private var selectedUser: UserResponse? = nil
    
    var body: some View {
        VStack {
            searchBox
                .padding([.top, .horizontal])
            
            if viewModel.searchText.isEmpty {
                VStack {
                    FontIcon.text(.materialIcon(code: .person_pin), fontsize: 56)
                    
                    Text("ユーザーを検索しよう！")
                        .font(.headline)
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                if viewModel.searchResults.isEmpty {
                    Text("「\(viewModel.searchText)」に一致するユーザーIDが見つかりません")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.bottom, 24)

                } else {
                    searchResultList
                }
            }
        }
        .background(.mainBackground)
        .onAppear {
            isModal = isPresented //モーダルかどうかの判定。即時適応不可だったのでAppearで
            isFocused = true
        }
        .navigationTitle("ユーザーID検索")
        //検索時はモーダルを閉じないように
        .interactiveDismissDisabled(!viewModel.searchText.isEmpty)
        .sheet(item: $selectedUser) { user in
            UserDetailView(user: user) // 選択されたユーザーを引数として渡す
        }
    }
    
    private var searchBox: some View {
        HStack(spacing: 16) {
            // モーダルの場合は閉じるボタンを表示
            if isModal {
                FontIcon.button(.materialIcon(code: .close), action: {
                    dismiss()
                }, fontsize: 28)
                .padding(12)
                .background(.item)
                .clipShape(Circle())
            }
            
            FocusedTextField(placeholder: "ユーザーIDを検索",
                             text: $viewModel.searchText)
            .frame(height: 48)
            .keyboardType(.alphabet)
        }
    }
    
    private var searchResultList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.searchResults, id: \.id) { user in
                    
                    Button(action: {
                        self.selectedUser = user
                    }, label: {
                        UserCell(user: user)
                    })
                    
                    Rectangle()
                        .frame(height: 2)
                        .padding(.horizontal)
                        .clipShape(Capsule())
                        .foregroundStyle(.secondary.opacity(0.1))
                }
            }
            .padding(12)
        }
    }
}

#Preview {
    AddFriendsView()
}

import Combine

@MainActor
class AddFriendsViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [UserResponse] = []
    private var searchTextObserver: AnyCancellable?
    
    init() {
        searchTextObserver = $searchText
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink(receiveValue: searchUsers)
    }
    
    private func searchUsers(for searchText: String) {
        let sanitizedSearchText = searchText.replacingOccurrences(of: "@", with: "")
        Task {
            let result = await FirebaseManager.shared
                .searchUsers(byHandle: sanitizedSearchText)
            
            switch result {
            case .success(let users):
                self.searchResults = users
            case .failure(_):
                self.searchResults = []
            }
        }
    }
}
