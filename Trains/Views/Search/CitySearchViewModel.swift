//
//  CitySearchViewModel.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 12.01.2026.
//

import SwiftUI

@MainActor
@Observable
final class CitySearchViewModel {
    // MARK: - Properties
    let context: AppRoute.CitySearchContext
    let initialCity: String
    
    var searchText: String = ""
    
    struct CityItem: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let originalIndex: Int
    }
    
    var allCities: [CityItem] = []
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    var dataHash: String {
        allCities.map { $0.name }.joined(separator: "|") + "|count:\(allCities.count)"
    }
    
    var filteredCities: [CityItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if query.isEmpty {
            return allCities
        }
        
        return allCities.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    var navigationTitle: String {
        context.title
    }
    
    var searchPlaceholder: String {
        "Введите название города"
    }
    
    var notFoundText: String {
        if isLoading {
            return "Загрузка..."
        }
        
        if let error = errorMessage {
            return "Ошибка: \(error)"
        }
        
        if !searchText.isEmpty && filteredCities.isEmpty {
            return "Город '\(searchText)' не найден"
        }
        
        return "Введите название города"
    }
    
    // MARK: - Initialization
    init(context: AppRoute.CitySearchContext, initialCity: String) {
        self.context = context
        self.initialCity = initialCity
        self.searchText = initialCity
    }
    
    // MARK: - Methods
    @MainActor
    func loadCities() async {
        // Проверяем, если уже загружено, не загружаем снова
        if !allCities.isEmpty && !searchText.isEmpty && !filteredCities.isEmpty {
            isLoading = false
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Используем shared сервис
            let cityNames = try await CityService.shared.getAllCities(cached: true)
            
            // Преобразуем в CityItem с уникальными ID
            allCities = cityNames.enumerated().map { index, name in
                CityItem(name: name, originalIndex: index)
            }
            
            print("✅ Загружено \(allCities.count) городов")
        } catch {
            errorMessage = "Не удалось загрузить города"
            print("❌ Ошибка загрузки городов: \(error)")
            
            let testCities = [
                "Москва",
                "Санкт-Петербург",
                "Сочи",
                "Горный воздух",
                "Краснодар",
                "Казань",
                "Омск"
            ]
            
            allCities = testCities.enumerated().map { index, name in
                CityItem(name: name, originalIndex: index)
            }
        }
        
        isLoading = false
    }
    
    func selectCity(_ city: String) -> AppRoute {
        AppRoute.stationSearch(context: context, city: city, station: "")
    }
    
    func clearSearch() {
        searchText = ""
    }
}
