//
//  GlobalErrorPresenter.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 24.12.2025.
//

import SwiftUI

struct GlobalErrorPresenter: ViewModifier {
    
    // MARK: - Properties
    
    @State private var appState = AppState.shared
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content
            .environment(appState) // Делаем доступным для вложенных вью
            .overlay(
                errorOverlay
            )
    }
    
    // MARK: - UI Components
    
    private var errorOverlay: some View {
        ZStack {
            if let error = appState.errorState {
                ErrorStateView(state: error)
                    .transition(.opacity)
                    .zIndex(1)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .animation(.default, value: appState.errorState)
    }
}

// MARK: - View Extension

extension View {
    func withGlobalErrors() -> some View {
        self.modifier(GlobalErrorPresenter())
    }
}
