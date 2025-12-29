//
//  SettingsView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 24.12.2025.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Body
    
    var body: some View {
        List {
            mainSection
            aboutSection
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Sections
    
    private var mainSection: some View {
        Section("Основное") {
            notificationsRow
            darkThemeRow
        }
    }
    
    private var aboutSection: some View {
        Section("О приложении") {
            versionRow
            developerRow
        }
    }
    
    // MARK: - Settings Rows
    
    private var notificationsRow: some View {
        HStack {
            Image(systemName: "bell.fill")
                .foregroundColor(.ypBlue)
            
            Text("Уведомления")
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
    }
    
    private var darkThemeRow: some View {
        HStack {
            Image(systemName: "moon.fill")
                .foregroundColor(.ypBlue)
            
            Text("Темная тема")
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
    }
    
    private var versionRow: some View {
        HStack {
            Text("Версия")
            
            Spacer()
            
            Text("1.0.0")
                .foregroundColor(.gray)
        }
    }
    
    private var developerRow: some View {
        HStack {
            Text("Разработчик")
            
            Spacer()
            
            Text("Trains Team")
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView()
    }
}
