//
//  RoomsCell.swift
//  ReportChat
//
//  Created by SATTSAT on 2024/09/17
//
//

import SwiftUI
import SwiftUIFontIcon

struct RoomCell: View {
    
    @ObservedObject var viewModel: RoomViewModel
    private let iconSize: CGFloat = 48
    
    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let iconUrl = viewModel.iconUrlString {
                    CachedImage(url: iconUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            Rectangle().aspectRatio(1, contentMode: .fill)
                                .overlay {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                }
                                .clipped()
                        case .failure(_):
                            FontIcon.text(.materialIcon(code: .account_circle),
                                          fontsize: iconSize)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    FontIcon.text(.materialIcon(code: .account_circle),
                                  fontsize: iconSize)
                }
            }
            .frame(width: iconSize, height: iconSize)
            .clipShape(Circle())
            
            Text(viewModel.roomName)
                .font(.subheadline)
            
            Spacer()
            
            FontIcon.text(.materialIcon(code: .report),
                          fontsize: iconSize)
            .foregroundStyle(.red)
            .hidden(!viewModel.isUnread)
            
            Text(viewModel.room.lastUpdated.toLastUpdatedString())
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
            roomName: "room サンプル",
            lastUpdated: Date(),
            readUsers: [:]
        )))
}
