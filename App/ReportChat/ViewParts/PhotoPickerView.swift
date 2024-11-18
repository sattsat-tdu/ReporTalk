//
//  PhotoPickerView2.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/11/19
//  
//

import SwiftUI

public struct PhotoPickerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss: DismissAction

    @Binding private var imageData: Data?

    public init(imageData: Binding<Data?>) {
        self._imageData = imageData
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let uiImagePickerController = UIImagePickerController()
        uiImagePickerController.delegate = context.coordinator
        uiImagePickerController.sourceType = .photoLibrary
        uiImagePickerController.allowsEditing = true
        return uiImagePickerController
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: PhotoPickerView

        public init(_ parent: PhotoPickerView) {
            self.parent = parent
        }

        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.editedImage] as? UIImage {
                parent.imageData = image.jpegData(compressionQuality: 0.8) // Convert UIImage to Data
            } else if let image = info[.originalImage] as? UIImage {
                parent.imageData = image.jpegData(compressionQuality: 0.8) // Convert UIImage to Data
            }
            parent.dismiss()
        }
    }
}
