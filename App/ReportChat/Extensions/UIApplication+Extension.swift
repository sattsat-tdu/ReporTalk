//
//  UIApplication+Extension.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/27
//  
//

import Foundation
import UIKit
import SwiftUI

extension UIApplication {
    private enum WindowLevel: Int {
        case modal = 1
        case dialog
        case toast
        case tutorial
    }
    
    static var dialogWindow: UIWindow?
    static var loadingWindow: UIWindow?
    static var toastWindow: UIWindow?
    static var modalWindow: UIWindow?
    
    static var toastQueue: [(ShowType, String)] = []
    
    //ダイアログの表示
    static func showDialog<Content: View>(content: Content) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        
        let newWindow = UIWindow(windowScene: windowScene)
        let vc = UIHostingController(rootView: content)
        
        vc.view.backgroundColor = .clear
        newWindow.rootViewController = vc
        newWindow.windowLevel = UIWindow.Level.alert + 1
        UIApplication.dialogWindow = newWindow
        newWindow.makeKeyAndVisible()
    }
    
    static func hideDialog() {
        dialogWindow = nil
    }
    
    //ローディングViewの表示
    static func showLoading(message: String? = "ロード中") {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        
        let newWindow = UIWindow(windowScene: windowScene)
        let vc = UIHostingController(rootView: LoadingView(message: message!))
        
        vc.view.backgroundColor = .clear
        newWindow.rootViewController = vc
        newWindow.windowLevel = UIWindow.Level.alert + 1
        UIApplication.loadingWindow = newWindow
        newWindow.makeKeyAndVisible()
    }
    
    static func hideLoading() {
        loadingWindow = nil
    }
    
    static func showToast(type: ShowType, message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        
        // 既にトーストが表示されている場合、キューに追加する
        if toastWindow != nil {
            toastQueue.append((type, message))
            return
        }
        
        let toastHeight: CGFloat = 100
        let toastFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: toastHeight)
        
        let newWindow = UIWindow(windowScene: windowScene)
        newWindow.frame = toastFrame // トースト部分のみのウィンドウに設定
        let vc = UIHostingController(
            rootView: ToastView(
                type: type,
                message: message,
                onHided: {
                    toastWindow = nil
                    
                    // キューにある次のトーストを表示
                    if !UIApplication.toastQueue.isEmpty {
                        let nextToast = toastQueue.removeFirst()
                        showToast(type: nextToast.0, message: nextToast.1)
                    }
                })
        )
        vc.view.backgroundColor = .clear
        newWindow.rootViewController = vc
        newWindow.windowLevel = UIWindow.Level.alert + 1
        UIApplication.toastWindow = newWindow
        newWindow.makeKeyAndVisible()
    }
    
    static func showModal(modalItem: ModalItem) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        
        let newWindow = UIWindow(windowScene: windowScene)
        let vc = UIHostingController(rootView: ModalView(modalItem: modalItem))
        
        vc.view.backgroundColor = .clear
        newWindow.rootViewController = vc
        newWindow.windowLevel = UIWindow.Level.alert + 1
        modalWindow = newWindow
        newWindow.makeKeyAndVisible()
    }
    
    static func hideModel() {
        modalWindow = nil
    }
}
