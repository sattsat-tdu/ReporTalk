//
//  HandleChecker.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/11/26
//  
//

import Foundation

enum HandleNameError: String, Error {
    case empty = "ハンドルネームを入力してください。"
    case alreadyInUse = "すでに利用されています。"
    case invalidBoundaryCharacter = "文頭や文末に (_) または (.) を使用できません。"
    case invalidFormat = "(_)と(.)以外の特殊文字は禁止されています。"
    case tooShort = "6文字以上にしてください。"
    case tooLong = "20文字以内にしてください。"
    case onlyNumber = "数字のみの登録はできません"
    case containsUppercase = "大文字が含まれています。"
    case serverError = "サーバーエラーが発生しています。"
}

struct HandleChecker {
    // ハンドルネームのバリデーションを行う関数
    static func validate(handleName: String) -> Result<Void, HandleNameError> {
        guard !handleName.isEmpty else {
            return .failure(.empty)
        }

        // 1. 文頭または文末に (_) または (.) がないか
        if handleName.hasPrefix("_") || handleName.hasPrefix(".") ||
           handleName.hasSuffix("_") || handleName.hasSuffix(".") {
            return .failure(.invalidBoundaryCharacter)
        }

        // 2. (_) または (.) だけで構成されていないか
        if handleName.matches("^[_.]+$") {
            return .failure(.invalidBoundaryCharacter)
        }

        // 3. 大文字を含まないか
        if handleName.matches(".*[A-Z]+.*") {
            return .failure(.containsUppercase)
        }

        // 4. 数字のみではないか
        if handleName.matches("^[0-9]+$") {
            return .failure(.onlyNumber)
        }

        // 5. 禁止文字を含まないか
        if !handleName.matches("^[a-z0-9_.]+$") {
            return .failure(.invalidFormat)
        }

        // 6. 長さが適切か
        if handleName.count < 6 {
            return .failure(.tooShort)
        }
        if handleName.count > 20 {
            return .failure(.tooLong)
        }

        return .success(())
    }

    // Firebaseを使った重複チェック
    static func checkAvailability(handleName: String) async -> Result<Void, HandleNameError> {
        let result = await FirebaseManager.shared.checkHandleNameAvailibility(handleName: handleName)
        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
}
