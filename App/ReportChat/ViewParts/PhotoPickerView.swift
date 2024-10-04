//
//  PhotoPickerView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/30
//  
//

import SwiftUI
import PhotosUI
import SwiftUIFontIcon

struct PhotoPickerView: View {
    
    @State var selectedPhoto: PhotosPickerItem?
    @Binding var selectedImageData: Data?
    
    var body: some View {
        PhotosPicker(selection: $selectedPhoto,
                     matching: .images,
                     photoLibrary: .shared()
        ){
            if let imageData = selectedImageData,
               let uiImage = UIImage(data: imageData){
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(height: 80)
                    .shadow(radius: 3)
            } else {
                FontIcon.text(.materialIcon(code: .account_circle), fontsize: 80)
                    .foregroundStyle(.fieldBack)
            }
        }
        .onChange(of: selectedPhoto) {
            if let selectedImageData = selectedPhoto {
                selectedImageData.loadTransferable(type: Data.self) { result in
                    switch result {
                    case .success(let data):
                        if let data = data {
                            self.selectedImageData = data
                        }
                    case .failure:
                        return
                    }
                }
            }
        }
    }
}

#Preview {
    PhotoPickerView(selectedImageData: .constant(Data()))
}
