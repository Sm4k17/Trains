//
//  SettingsViewModel.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 12.01.2026.
//

import SwiftUI

@Observable
final class SettingsViewModel {
    // MARK: - Private Storage
    @ObservationIgnored
    @AppStorage(AppStorageKeys.isDarkThemeEnabled)
    private var _isDarkThemeEnabled = false
    
    @ObservationIgnored
    @AppStorage(AppStorageKeys.didBootstrapTheme)
    private var _didBootstrapTheme = false
    
    // MARK: - Public Interface
    var isDarkThemeEnabled: Bool {
        get { _isDarkThemeEnabled }
        set {
            _isDarkThemeEnabled = newValue
            if newValue {
                _didBootstrapTheme = true
            }
        }
    }
    
    var didBootstrapTheme: Bool {
        get { _didBootstrapTheme }
        set { _didBootstrapTheme = newValue }
    }
    
    // MARK: - Computed Properties
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildVersion: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "beta"
    }
    
    var apiInfoText: String {
        "Приложение использует API «Яндекс.Расписания»"
    }
    
    var fullVersionString: String {
        "Версия \(appVersion) (\(buildVersion))"
    }
    
    // MARK: - Methods
    func toggleTheme() {
        isDarkThemeEnabled.toggle()
        // Флаг _didBootstrapTheme уже установится в сеттере isDarkThemeEnabled
    }
}
