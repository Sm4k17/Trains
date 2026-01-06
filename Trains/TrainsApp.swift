//
//  TrainsApp.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 17.11.2025.
//

import SwiftUI

@main
struct TrainsApp: App {
    @AppStorage(AppStorageKeys.isDarkThemeEnabled) private var isDarkThemeEnabled = false
    @AppStorage(AppStorageKeys.didBootstrapTheme) private var didBootstrapTheme = false
    var body: some Scene {
        WindowGroup {
            MainTabView()
                // Больше не нужно передавать environment здесь
                // AppState.shared будет доступен через GlobalErrorPresenter
                .withGlobalErrors()
                .preferredColorScheme(isDarkThemeEnabled ? .dark : .light)
        }
    }
}
