//
//  CloseButtonView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 06.01.2026.
//

import SwiftUI

struct CloseButtonView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(.close)
                .resizable()
                .scaledToFit()
        }
        .frame(width: 30, height: 30)
        .background(Color.ypBlackUniversal)
        .clipShape(Circle())
        .contentShape(Circle())
        .accessibilityLabel("Закрыть")
        .accessibilityHint("Закрывает текущий экран")
    }
}
