//
//  SettingsView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 24.12.2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("Основное") {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.ypBlue)
                    Text("Уведомления")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                
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
            
            Section("О приложении") {
                HStack {
                    Text("Версия")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Разработчик")
                    Spacer()
                    Text("Trains Team")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
