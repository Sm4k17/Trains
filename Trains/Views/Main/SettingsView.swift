//
//  SettingsView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 24.12.2025.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage(AppStorageKeys.isDarkThemeEnabled) private var isDarkThemeEnabled = false
    @AppStorage(AppStorageKeys.didBootstrapTheme) private var didBootstrapTheme = false
    
    @Binding var navigationPath: NavigationPath
    
    private enum Theme {
        static let onColor: Color = .ypBlue
        static let offColor: Color = .ypGray.opacity(0.3)
        static let thumbColor: Color = .white
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            List {
                HStack {
                    Text("Темная тема")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.ypBlack)
                    Spacer()
                    Toggle("", isOn: $isDarkThemeEnabled)
                        .labelsHidden()
                        .tint(Theme.onColor)
                        .onChange(of: isDarkThemeEnabled) { _, _ in
                            didBootstrapTheme = true
                        }
                }
                .listRowInsets(.init(top: 19, leading: 16, bottom: 19, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .padding(.top, 24)
                
                Button {
                    navigationPath.append(AppRoute.userAgreement)
                } label: {
                    HStack {
                        Text("Пользовательское соглашение")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.ypBlack)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .frame(width: 24.0, height: 24.0)
                            .foregroundColor(.ypBlack)
                    }
                }
                .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 60)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // На корневом экране Settings кнопки "назад" нет
        }
        
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 6) {
                Text("Приложение использует API «Яндекс.Расписания»")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.ypBlack)
                    .multilineTextAlignment(.center)
                Text("Версия 1.0 (beta)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.ypBlack)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .background(Color(.systemBackground))
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var navigationPath = NavigationPath()
        
        var body: some View {
            NavigationStack {
                SettingsView(navigationPath: $navigationPath)
            }
            .preferredColorScheme(.light)
        }
    }
    
    return PreviewWrapper()
}

#Preview("Dark") {
    struct PreviewWrapper: View {
        @State private var navigationPath = NavigationPath()
        
        var body: some View {
            NavigationStack {
                SettingsView(navigationPath: $navigationPath)
            }
            .preferredColorScheme(.dark)
        }
    }
    
    return PreviewWrapper()
}
