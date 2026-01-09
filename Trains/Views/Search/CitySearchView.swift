//
//  CitySearchView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

struct CitySearchView: View {
    
    // MARK: - Properties
    
    let context: AppRoute.CitySearchContext
    let initialCity: String
    @Binding var navigationPath: NavigationPath
    @Binding var fromCity: String
    @Binding var toCity: String
    
    // MARK: - State
    
    @State private var searchText: String = ""
    @State private var selectedCity: String? = nil
    
    // MARK: - Constants
    
    private struct Constants {
        enum Padding {
            static let horizontal: CGFloat = 16
            static let rowVertical: CGFloat = 4
            static let searchTop: CGFloat = 8
            static let searchBottom: CGFloat = 4
            static let clearHit: CGFloat = 8
            static let clearTrailing: CGFloat = 14
        }
        
        enum Size {
            static let rowHeight: CGFloat = 60
            static let backButton: CGFloat = 44
        }
        
        enum CornerRadius {
            static let search: CGFloat = 10
        }
        
        enum FontSize {
            static let notFound: CGFloat = 24
            static let city: CGFloat = 17
        }
        
        enum Opacity {
            static let chevronRight: Double = 0.6
        }
        
        enum Offset {
            static let notFoundTop: CGFloat = 228
        }
        
        enum ClearIcon {
            static let name = "xmark.circle.fill"
            static let textTrailingInset: CGFloat = 34
        }
    }
    
    // MARK: - Mock Data
    
    private let cities = [
        "Москва",
        "Санкт-Петербург",
        "Сочи",
        "Горный воздух",
        "Краснодар",
        "Казань",
        "Омск"
    ]
    
    // MARK: - Computed Properties
    
    private var filteredCities: [String] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty
        ? cities
        : cities.filter { $0.localizedCaseInsensitiveContains(query) }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            searchField
            
            if filteredCities.isEmpty {
                notFoundView
            } else {
                cityList
            }
        }
        .navigationTitle(context.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    // Возвращаемся назад
                    navigationPath.removeLast()
                }
            }
        }
        .onAppear {
            searchText = initialCity
        }
    }
    
    // MARK: - UI Components
    
    private var searchField: some View {
        SearchTextField(
            text: $searchText,
            placeholder: "Введите запрос"
        )
        .padding(.horizontal, Constants.Padding.horizontal)
        .padding(.top, Constants.Padding.searchTop)
        .padding(.bottom, Constants.Padding.searchBottom)
    }
    
    private var cityList: some View {
        List(filteredCities, id: \.self) { city in
            cityRow(for: city)
        }
        .listStyle(.plain)
    }
    
    private func cityRow(for city: String) -> some View {
        HStack {
            Text(city)
                .font(.system(size: Constants.FontSize.city, weight: .regular))
                .foregroundColor(.ypBlack)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.ypBlack)
                .opacity(Constants.Opacity.chevronRight)
        }
        .frame(height: Constants.Size.rowHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            // Переходим к выбору станции
            navigationPath.append(
                AppRoute.stationSearch(context: context, city: city, station: "")
            )
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(
            top: 0,
            leading: 16,
            bottom: 0,
            trailing: 16
        ))
    }
    
    private var notFoundView: some View {
        VStack {
            Spacer()
                .frame(height: Constants.Offset.notFoundTop)
            
            Text("Город не найден")
                .font(.system(size: Constants.FontSize.notFound, weight: .bold))
                .foregroundColor(.ypBlack)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var navigationPath = NavigationPath()
        @State private var fromCity = ""
        @State private var toCity = ""
        
        var body: some View {
            NavigationStack {
                CitySearchView(
                    context: .from,
                    initialCity: "",
                    navigationPath: $navigationPath,
                    fromCity: $fromCity,
                    toCity: $toCity
                )
            }
        }
    }
    
    return PreviewWrapper()
}
