//
//  RouteInputSectionView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 24.12.2025.
//

import SwiftUI

struct RouteInputSectionView: View {
    
    private enum Constants {
        enum Padding {
            static let horizontal: CGFloat = 16.0
            static let vertical: CGFloat = 16.0
            static let leading: CGFloat = 20.0
        }
        enum Size {
            static let viewHeight: CGFloat = 128.0
            static let button: CGFloat = 36.0
            static let searchButtonWidth: CGFloat = 150.0
            static let searchButtonHeight: CGFloat = 60.0
        }
        enum Spacing {
            static let view: CGFloat = 12.0
            static let field: CGFloat = 8.0
        }
        enum FontSize {
            static let label: CGFloat = 17.0
            static let labelButton: CGFloat = 17
        }
        enum Colors {
            static let textField: Color = .ypGray
            static let squarepathButton: Color = .ypWhiteUniversal
            static let cardBackground: Color = .ypWhiteUniversal
            static let searchButtonBackground: Color = .ypBlue
        }
        enum CornerRadius {
            static let view: Double = 20.0
            static let searchButton: CGFloat = 16.0
        }
        enum Animation {
            static let duration: Double = 0.2
            static let swapSpringResponse: Double = 0.25
            static let swapSpringDamping: Double = 0.9
        }
        enum Placeholder {
            static let from = "Откуда"
            static let to   = "Куда"
        }
        enum Titles {
            static let searchButton = "Найти"
        }
        enum Images {
            enum System {
                static let squarePathButton = "arrow.2.squarepath"
            }
        }
    }
    
    @Binding var navigationPath: NavigationPath
    @Binding var from: String
    @Binding var to: String
    
    @State private var isShowingFromSearch = false
    @State private var isShowingToSearch = false
    
    private var hasBothInputs: Bool {
        !from.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !to.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(spacing: Constants.Spacing.view) {
            ZStack {
                Color.ypBlue.cornerRadius(Constants.CornerRadius.view)
                HStack {
                    searchCityField
                    squarePathButton
                }
                .padding(.horizontal, Constants.Padding.horizontal)
                .padding(.vertical, Constants.Padding.vertical)
            }
            .frame(height: Constants.Size.viewHeight)
            .padding(.horizontal, Constants.Padding.horizontal)
            
            if hasBothInputs {
                Button {
                    navigationPath.append("CarrierList")
                } label: {
                    Text(Constants.Titles.searchButton)
                        .font(.system(size: Constants.FontSize.labelButton, weight: .bold))
                        .foregroundColor(.ypWhiteUniversal)
                        .frame(width: Constants.Size.searchButtonWidth, height: Constants.Size.searchButtonHeight)
                        .background(Constants.Colors.searchButtonBackground)
                        .cornerRadius(Constants.CornerRadius.searchButton)
                }
                .buttonStyle(.plain)
                .disabled(!hasBothInputs)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: Constants.Animation.duration), value: hasBothInputs)
        .fullScreenCover(isPresented: $isShowingFromSearch) {
            CitySearchView { city in
                from = city
                isShowingFromSearch = false
            }
        }
        .fullScreenCover(isPresented: $isShowingToSearch) {
            CitySearchView { city in
                to = city
                isShowingToSearch = false
            }
        }
    }
    
    private var searchCityField: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: Constants.Spacing.field) {
                    Button { isShowingFromSearch = true } label: {
                        HStack {
                            Text(from.isEmpty ? Constants.Placeholder.from : from)
                                .foregroundColor(from.isEmpty ? Constants.Colors.textField : .ypBlackUniversal)
                                .font(.system(size: Constants.FontSize.label, weight: .regular))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Spacer().frame(height: 14)
                    
                    Button { isShowingToSearch = true } label: {
                        HStack {
                            Text(to.isEmpty ? Constants.Placeholder.to : to)
                                .foregroundColor(to.isEmpty ? Constants.Colors.textField : .ypBlackUniversal)
                                .font(.system(size: Constants.FontSize.label, weight: .regular))
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, Constants.Padding.vertical)
                .padding(.horizontal, Constants.Padding.leading)
                .background(Color.ypWhiteUniversal)
                .cornerRadius(Constants.CornerRadius.view)
                .frame(height: 96)
            }
        }
    }
    
    private var squarePathButton: some View {
        let isDisabled = from.isEmpty && to.isEmpty
        
        return Button {
            withAnimation(.spring(response: Constants.Animation.swapSpringResponse,
                                  dampingFraction: Constants.Animation.swapSpringDamping)) {
                swap(&from, &to)
            }
        } label: {
            Image(systemName: Constants.Images.System.squarePathButton)
                .foregroundColor(.ypBlue)
                .frame(width: Constants.Size.button, height: Constants.Size.button)
        }
        .background(Constants.Colors.squarepathButton)
        .clipShape(Circle())
        .disabled(isDisabled)
    }
}

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
