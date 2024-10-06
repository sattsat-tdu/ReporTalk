//
//  RoomsCell.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/09/17
//
//

import SwiftUI

struct RoomCell: View {
    
    @ObservedObject var viewModel: RoomViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            //            if let imageUrlString = viewModel.roomIconUrlString {
            //                IconImageView(
            //                    urlString: imageUrlString,
            //                    size: 48
            //                )
            //                .clipShape(Circle())
            //            } else {
            //                Image("ninjinIMG")
            //                    .resizable()
            //                    .frame(width: 48, height: 48)
            //                    .clipShape(Circle())
            //            }
            Group {
                if let icon = viewModel.roomIcon {
                    Rectangle().aspectRatio(1, contentMode: .fill)
                        .overlay {
                            Image(uiImage: icon)
                                .resizable()
                                .scaledToFill()
                        }
                        .clipped()
                        .frame(width: 48, height: 48)
                }
                else {
                    Image("ninjinIMG")
                        .resizable()
                        .frame(width: 48, height: 48)
                }
            }
            .clipShape(Circle())
            
            
            Text(viewModel.roomName)
                .font(.subheadline)
            
            Spacer()
            
            Text("昨日")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
        .frame(height: 48)
        .padding(8)
    }
    
    
}

#Preview {
    RoomCell(
        viewModel: RoomViewModel(room: RoomResponse(
            id: "12345",
            members: ["Friend 1", "Friend 2"],
            roomIcon: "https://1.bp.blogspot.com/-_CVATibRMZQ/XQjt4fzUmjI/AAAAAAABTNY/nprVPKTfsHcihF4py1KrLfIqioNc_c41gCLcBGAs/s400/animal_chara_smartphone_penguin.png",
            roomName: "room サンプル"
        )))
}
