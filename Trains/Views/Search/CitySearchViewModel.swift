//
//  CitySearchViewModel.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 12.01.2026.
//

import SwiftUI

@Observable
final class CitySearchViewModel {
    // MARK: - Properties
    let context: AppRoute.CitySearchContext
    let initialCity: String
    
    var searchText: String = ""
    
    // MARK: - Mock Data (изолируем от View)
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
    var filteredCities: [String] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty
        ? cities
        : cities.filter { $0.localizedCaseInsensitiveContains(query) }
    }
    
    var navigationTitle: String {
        context.title
    }
    
    var searchPlaceholder: String {
        "Введите запрос"
    }
    
    var notFoundText: String {
        "Город не найден"
    }
    
    // MARK: - Initialization
    init(context: AppRoute.CitySearchContext, initialCity: String) {
        self.context = context
        self.initialCity = initialCity
        self.searchText = initialCity
    }
    
    // MARK: - Methods
    func selectCity(_ city: String) -> AppRoute {
        AppRoute.stationSearch(context: context, city: city, station: "")
    }
    
    func clearSearch() {
        searchText = ""
    }
}
