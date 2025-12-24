//
//  SearchTextField.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

struct SearchTextField: View {
    @Binding var text: String
    var placeholder: String
    var leadingSystemImage: String = "magnifyingglass"
    
    private enum UI {
        static let innerPadding: CGFloat = 10
        static let corner: CGFloat = 10
        static let textTrailingInsetForClear: CGFloat = 30
        static let clearIcon = "xmark.circle.fill"
        static let clearHitVPadding: CGFloat = 8
        static let clearTrailingPadding: CGFloat = 6
        static let bgOpacity: Double = 0.15
    }
    
    var body: some View {
        HStack {
            Image(systemName: leadingSystemImage).foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .foregroundColor(.primary)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .padding(.trailing, UI.textTrailingInsetForClear)
        }
        .padding(UI.innerPadding)
        .background(Color.ypGray.opacity(UI.bgOpacity))
        .cornerRadius(UI.corner)
        .overlay(alignment: .trailing) {
            if !text.isEmpty {
                Button {
                    withAnimation(.default) { text = "" }
                } label: {
                    Image(systemName: UI.clearIcon)
                        .foregroundColor(.secondary)
                        .imageScale(.medium)
                        .padding(.vertical, UI.clearHitVPadding)
                }
                .padding(.trailing, UI.clearTrailingPadding)
                .accessibilityLabel("Очистить")
            }
        }
    }
}

#Preview {
    @State var text = "Москва"
    return SearchTextField(text: $text, placeholder: "Поиск города")
        .padding()
}
