//
//  SelectTagView.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/11/09
//  
//

import SwiftUI
import SwiftUIFontIcon
struct SelectTagView: View {
    
    @Binding var flg: Bool
    @Binding var reportag: Reportag?
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false ) {
            VStack {
                HStack {
                    Text("レポータグを選択")
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        reportag = nil
                        flg.toggle()
                    }, label: {
                        Text("タグを取り除く")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(4)
                            .background(.gray)
                            .clipShape(.rect(cornerRadius: 8))
                    })
                    .hidden(reportag == nil)
                }
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Reportag.allCases, id: \.self) { tag in
                        Button(action: {
                            reportag = tag
                            flg.toggle()
                        }, label: {
                            Text(tag.tagName)
                                .foregroundStyle(.primary)
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(tag.color.gradient)
                                .clipShape(BubbleShape())
                        })
                    }
                }
                
                Spacer().frame(height: 48)
                
                CapsuleButton(
                    icon: .close,
                    style: .normal,
                    text: "閉じる",
                    onClicked: {
                        flg.toggle()
                    }
                )
            }
            .padding()
        }
        .padding(.top)
    }
}

#Preview {
    SelectTagView(flg: .constant(true), reportag: .constant(nil))
}

struct BubbleShape: Shape {
    func path(in rect:CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 20, y: height))
        path.addLine(to: CGPoint(x: width - 15, y: height))
        path.addCurve(to: CGPoint(x: width, y: height - 15),
                      controlPoint1: CGPoint(x: width - 8, y: height),
                      controlPoint2: CGPoint(x: width, y: height - 8))
        path.addLine(to: CGPoint(x: width, y: 15))
        path.addCurve(to: CGPoint(x: width - 15, y: 0),
                      controlPoint1: CGPoint(x: width, y: 8),
                      controlPoint2: CGPoint(x: width - 8, y: 0))
        path.addLine(to: CGPoint(x: 20, y: 0))
        path.addCurve(to: CGPoint(x: 5, y: 15),
                      controlPoint1: CGPoint(x: 12, y: 0),
                      controlPoint2: CGPoint(x: 5, y: 8))
        path.addLine(to: CGPoint(x: 5, y: height - 10))
        path.addCurve(to: CGPoint(x: 0, y: height),
                      controlPoint1: CGPoint(x: 5, y: height - 1),
                      controlPoint2: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: -1, y: height))
        path.addCurve(to: CGPoint(x: 12, y: height - 4),
                      controlPoint1: CGPoint(x: 4, y: height + 1),
                      controlPoint2: CGPoint(x: 8, y: height - 1))
        
        
        return Path(path.cgPath)
    }
}
