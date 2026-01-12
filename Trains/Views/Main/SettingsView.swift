//
//  SettingsView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 24.12.2025.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Properties
    @State private var viewModel = SettingsViewModel()
    @Binding var navigationPath: NavigationPath
    
    private enum Theme {
        static let onColor: Color = .ypBlue
        static let offColor: Color = .ypGray.opacity(0.3)
        static let thumbColor: Color = .white
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            List {
                themeSection
                userAgreementSection
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
            footerSection
        }
    }
    
    // MARK: - Subviews
    private var themeSection: some View {
        HStack {
            Text("Темная тема")
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.ypBlack)
            Spacer()
            Toggle("", isOn: $viewModel.isDarkThemeEnabled)
                .labelsHidden()
                .tint(Theme.onColor)
        }
        .listRowInsets(.init(top: 19, leading: 16, bottom: 19, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .padding(.top, 24)
    }
    
    private var userAgreementSection: some View {
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
    
    private var footerSection: some View {
        VStack(spacing: 6) {
            Text(viewModel.apiInfoText)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.ypBlack)
                .multilineTextAlignment(.center)
            Text(viewModel.fullVersionString)
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
