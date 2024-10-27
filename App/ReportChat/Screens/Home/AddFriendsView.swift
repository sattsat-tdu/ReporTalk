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
            HStack {
                SearchTextField(placeholder: "ユーザーIDを検索",
                                text: $viewModel.searchText)
                .focused($isFocused)
                .keyboardType(.alphabet)
                
                // モーダルの場合は閉じるボタンを表示
                if isModal {
                    FontIcon.button(.materialIcon(code: .close), action: {
                        dismiss()
                    }, fontsize: 24)
                    .padding(10)
                    .background(.tab)
                    .clipShape(Circle())
                }
            }
            
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
                    VStack {
                        Text("「\(viewModel.searchText)」に一致するユーザーIDが見つかりません")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                } else {
                    List(viewModel.searchResults, id: \.id) { user in
                        Button(action: {
                            self.selectedUser = user
                        }, label: {
                            UserCell(user: user)
                        })
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                }
            }
        }
        .padding()
        .background(.tab)
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
