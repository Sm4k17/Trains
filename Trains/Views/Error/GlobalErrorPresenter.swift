//
//  GlobalErrorPresenter.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 24.12.2025.
//

import SwiftUI

struct GlobalErrorPresenter: ViewModifier {
    // Используем синглтон напрямую
    @State private var appState = AppState.shared
    
    func body(content: Content) -> some View {
        content
            .environment(appState) // Делаем доступным для вложенных вью
            .overlay(
                ZStack {
                    if let error = appState.errorState {
                        ErrorStateView(state: error)
                            .transition(.opacity)
                            .zIndex(1)
                            .edgesIgnoringSafeArea(.all)
                    }
                }
                .animation(.default, value: appState.errorState)
            )
    }
}

extension View {
    func withGlobalErrors() -> some View {
        self.modifier(GlobalErrorPresenter())
    }
}
