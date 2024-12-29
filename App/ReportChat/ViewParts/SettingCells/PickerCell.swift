//
//  PickerCell.swift
//  ReportChat
//  
//  Created by SATTSAT on 2024/09/25
//  
//

import SwiftUI
import SwiftUIFontIcon

struct PickerCell: View {
    
    private let UD = UDManager.shared
    let pickerItem: PickerItem
    @State private var selection: String
    
    // initでUserDefaultsのキーを設定
    init(pickerItem: PickerItem) {
        self.pickerItem = pickerItem
        let savedValue = UD.get(forKey: pickerItem.key) as String?
        _selection = State(initialValue: savedValue ?? pickerItem.defaultOption)
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                if let icon = pickerItem.icon {
                    FontIcon.text(
                        .materialIcon(code: icon),
                        fontsize: 28
                    )
                }
                
                Picker(pickerItem.title, selection: $selection) {
                    ForEach(pickerItem.options, id: \.key) { option in
                        Text(option.value)
                            .tag(option.key)
                    }
                }
                .onChange(of: selection) {
                    // 選択された値をUserDefaultsに保存
                    UD.set(selection, forKey: pickerItem.key)
                    pickerItem.onChange?(selection)
                }
            }
            
            if let description = pickerItem.description {
                Text(description)
                    .font(.callout)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    PickerCell(
        pickerItem: PickerItem(
            key: SettingKeys.appearanceMode,
            icon: .smartphone,
            title: "ピッカー設定",
            description: "ピッカーを変更します。", 
            options: [
                PickerOption(key: "system", value: "端末に合わせる"),
                PickerOption(key: "light", value: "ライトモード"),
                PickerOption(key: "dark", value: "ダークモード")
            ], 
            defaultOption: "system",
            onChange: {_ in })
    )
}
