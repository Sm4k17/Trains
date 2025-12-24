//
//  ErrorStateView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 24.12.2025.
//

import SwiftUI

struct ErrorStateView: View {
    let state: ErrorState
    
    private let iconSize: CGFloat = 223
    private let corner: CGFloat = 70
    
    var body: some View {
        VStack(spacing: 16) {
            Image(state.assetName)
                .resizable()
                .renderingMode(.original)
                .scaledToFill()
                .frame(width: iconSize, height: iconSize)
                .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            
            Text(state.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            // Дополнительное сообщение для custom ошибок
            if case .custom(let message) = state, message != state.title {
                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        ErrorStateView(state: .offline)
        ErrorStateView(state: .server)
        ErrorStateView(state: .custom("Не удалось загрузить расписание"))
    }
    .environment(AppState.shared) // Добавьте если нужно AppState в превью
}
