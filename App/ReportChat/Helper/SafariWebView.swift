//
//  SafariWebView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/25
//  
//

import SafariServices
import SwiftUI

struct SafariWebView: UIViewControllerRepresentable {
  var url: URL

  func makeUIViewController(context: Context) -> SFSafariViewController {
    let safariViewController = SFSafariViewController(url: url)
    safariViewController.delegate = context.coordinator
    return safariViewController
  }

  func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, SFSafariViewControllerDelegate {
    var parent: SafariWebView

    init(_ safariWebView: SafariWebView) {
      self.parent = safariWebView
    }
  }
}
