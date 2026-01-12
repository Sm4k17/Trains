//
//  RouteInputSectionView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 24.12.2025.
//

import SwiftUI

struct RouteInputSectionView: View {
    
    // MARK: - Properties
    @Binding var navigationPath: NavigationPath
    @Binding var from: String
    @Binding var to: String
    
    // MARK: - Computed Properties
    private var hasBothInputs: Bool {
        RouteInputSectionViewModel.hasBothInputs(from: from, to: to)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: RouteInputSectionViewModel.Constants.Spacing.view) {
            ZStack {
                Color.ypBlue.cornerRadius(RouteInputSectionViewModel.Constants.CornerRadius.view)
                HStack {
                    searchCityField
                    squarePathButton
                }
                .padding(.horizontal, RouteInputSectionViewModel.Constants.Padding.horizontal)
                .padding(.vertical, RouteInputSectionViewModel.Constants.Padding.vertical)
            }
            .frame(height: RouteInputSectionViewModel.Constants.Size.viewHeight)
            .padding(.horizontal, RouteInputSectionViewModel.Constants.Padding.horizontal)
            
            // Резервируем место под кнопку — безопасно для жестов
            let buttonHeight = RouteInputSectionViewModel.Constants.Size.searchButtonHeight
            ZStack {
                Rectangle()
                    .fill(.clear)
                    .frame(height: buttonHeight)
                    .allowsHitTesting(false)
                
                if hasBothInputs {
                    searchButton
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }
            .animation(
                .easeOut(duration: 0.6)
                .delay(0.05),
                value: hasBothInputs
            )
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - UI Components
    
    private var searchCityField: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: RouteInputSectionViewModel.Constants.Spacing.field) {
                    fromFieldButton
                    
                    Spacer()
                        .frame(height: RouteInputSectionViewModel.Constants.Size.spacerHeight)
                    
                    toFieldButton
                }
                .padding(.vertical, RouteInputSectionViewModel.Constants.Padding.vertical)
                .padding(.horizontal, RouteInputSectionViewModel.Constants.Padding.leading)
                .background(Color.ypWhiteUniversal)
                .cornerRadius(RouteInputSectionViewModel.Constants.CornerRadius.view)
                .frame(height: RouteInputSectionViewModel.Constants.Size.fieldHeight)
            }
        }
    }
    
    private var fromFieldButton: some View {
        Button {
            // Переход к поиску города "Откуда"
            navigationPath.append(
                AppRoute.citySearch(
                    context: .from,
                    city: RouteInputSectionViewModel.getCityForSearch(from)
                )
            )
        } label: {
            HStack {
                Text(from.isEmpty ? RouteInputSectionViewModel.Constants.Placeholder.from : from)
                    .foregroundColor(from.isEmpty ? RouteInputSectionViewModel.Constants.Colors.textField : .ypBlackUniversal)
                    .font(.system(size: RouteInputSectionViewModel.Constants.FontSize.label, weight: .regular))
                    .animation(.default, value: from)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var toFieldButton: some View {
        Button {
            // Переход к поиску города "Куда"
            navigationPath.append(
                AppRoute.citySearch(
                    context: .to,
                    city: RouteInputSectionViewModel.getCityForSearch(to)
                )
            )
        } label: {
            HStack {
                Text(to.isEmpty ? RouteInputSectionViewModel.Constants.Placeholder.to : to)
                    .foregroundColor(to.isEmpty ? RouteInputSectionViewModel.Constants.Colors.textField : .ypBlackUniversal)
                    .font(.system(size: RouteInputSectionViewModel.Constants.FontSize.label, weight: .regular))
                    .animation(.default, value: to)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var squarePathButton: some View {
        Button {
            withAnimation(.spring(
                response: RouteInputSectionViewModel.Constants.Animation.swapSpringResponse,
                dampingFraction: RouteInputSectionViewModel.Constants.Animation.swapSpringDamping
            )) {
                swap(&from, &to)
            }
        } label: {
            Image(systemName: RouteInputSectionViewModel.Constants.Images.System.squarePathButton)
                .foregroundColor(.ypBlue)
                .frame(
                    width: RouteInputSectionViewModel.Constants.Size.button,
                    height: RouteInputSectionViewModel.Constants.Size.button
                )
        }
        .background(RouteInputSectionViewModel.Constants.Colors.squarepathButton)
        .clipShape(Circle())
        .disabled(from.isEmpty && to.isEmpty)
    }
    
    private var searchButton: some View {
        Button {
            // Переход к списку перевозчиков
            navigationPath.append(AppRoute.carrierList(from: from, to: to))
        } label: {
            Text(RouteInputSectionViewModel.Constants.Titles.searchButton)
                .font(.system(size: RouteInputSectionViewModel.Constants.FontSize.labelButton, weight: .bold))
                .foregroundColor(.ypWhiteUniversal)
                .frame(
                    width: RouteInputSectionViewModel.Constants.Size.searchButtonWidth,
                    height: RouteInputSectionViewModel.Constants.Size.searchButtonHeight
                )
                .background(RouteInputSectionViewModel.Constants.Colors.searchButtonBackground)
                .cornerRadius(RouteInputSectionViewModel.Constants.CornerRadius.searchButton)
        }
        .buttonStyle(.plain)
        .disabled(!hasBothInputs)
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var navigationPath = NavigationPath()
        @State private var from = ""
        @State private var to = ""
        
        var body: some View {
            NavigationStack {
                RouteInputSectionView(
                    navigationPath: $navigationPath,
                    from: $from,
                    to: $to
                )
            }
        }
    }
    
    return PreviewWrapper()
}
