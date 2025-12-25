//
//  ErrorStateView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 24.12.2025.
//

import SwiftUI

struct ErrorStateView: View {
    
    // MARK: - Properties
    
    let state: ErrorState
    
    // MARK: - Constants
    
    private struct Constants {
        static let iconSize: CGFloat = 223
        static let cornerRadius: CGFloat = 70
        static let spacing: CGFloat = 16
        static let horizontalPadding: CGFloat = 16
        static let messageHorizontalPadding: CGFloat = 20
        
        enum FontSize {
            static let title: CGFloat = 24
            static let message: CGFloat = 16
        }
        
        enum FontWeight {
            static let title: Font.Weight = .bold
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Constants.spacing) {
            errorIcon
            errorTitle
            errorMessage
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, Constants.horizontalPadding)
        .background(Color(.systemBackground))
    }
    
    // MARK: - UI Components
    
    private var errorIcon: some View {
        Image(state.assetName)
            .resizable()
            .renderingMode(.original)
            .scaledToFill()
            .frame(width: Constants.iconSize, height: Constants.iconSize)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: Constants.cornerRadius,
                    style: .continuous
                )
            )
    }
    
    private var errorTitle: some View {
        Text(state.title)
            .font(.system(
                size: Constants.FontSize.title,
                weight: Constants.FontWeight.title
            ))
            .foregroundColor(.primary)
    }
    
    @ViewBuilder
    private var errorMessage: some View {
        if case .custom(let message) = state, message != state.title {
            Text(message)
                .font(.system(size: Constants.FontSize.message))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.messageHorizontalPadding)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 30) {
        ErrorStateView(state: .offline)
        ErrorStateView(state: .server)
        ErrorStateView(state: .custom("Не удалось загрузить расписание"))
    }
}
