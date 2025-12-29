//
//  SearchTextField.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

struct SearchTextField: View {
    
    // MARK: - Properties
    
    @Binding var text: String
    var placeholder: String
    var leadingSystemImage: String = "magnifyingglass"
    
    // MARK: - Constants
    
    private struct Constants {
        static let innerPadding: CGFloat = 10
        static let cornerRadius: CGFloat = 10
        static let textTrailingInsetForClear: CGFloat = 30
        static let clearHitVPadding: CGFloat = 8
        static let clearTrailingPadding: CGFloat = 6
        static let bgOpacity: Double = 0.15
        
        enum Images {
            static let clearIcon = "xmark.circle.fill"
        }
        
        enum Accessibility {
            static let clearButtonLabel = "Очистить"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Image(systemName: leadingSystemImage)
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .foregroundColor(.primary)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .padding(.trailing, Constants.textTrailingInsetForClear)
        }
        .padding(Constants.innerPadding)
        .background(Color.ypGray.opacity(Constants.bgOpacity))
        .cornerRadius(Constants.cornerRadius)
        .overlay(alignment: .trailing) {
            clearButton
        }
    }
    
    // MARK: - UI Components
    
    @ViewBuilder
    private var clearButton: some View {
        if !text.isEmpty {
            Button {
                withAnimation(.default) { text = "" }
            } label: {
                Image(systemName: Constants.Images.clearIcon)
                    .foregroundColor(.secondary)
                    .imageScale(.medium)
                    .padding(.vertical, Constants.clearHitVPadding)
            }
            .padding(.trailing, Constants.clearTrailingPadding)
            .accessibilityLabel(Constants.Accessibility.clearButtonLabel)
        }
    }
}

// MARK: - Preview

#Preview {
    @State var text = "Москва"
    
    return SearchTextField(
        text: $text,
        placeholder: "Поиск города"
    )
    .padding()
}
