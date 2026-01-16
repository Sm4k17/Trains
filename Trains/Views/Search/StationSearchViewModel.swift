//
//  StationSearchViewModel.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 12.01.2026.
//

import SwiftUI

@MainActor
@Observable
final class StationSearchViewModel {
    // MARK: - Properties
    let city: String
    let initialStation: String
    let context: AppRoute.CitySearchContext
    
    var searchText: String = ""
    
    struct StationItem: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let originalIndex: Int
    }
    
    var allStations: [StationItem] = []
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Computed Properties
    var dataHash: String {
        allStations.map { $0.name }.joined(separator: "|") + "|count:\(allStations.count)"
    }
    
    var filteredStations: [StationItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if query.isEmpty {
            return allStations
        }
        
        return allStations.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    var navigationTitle: String {
        "Станции в \(city)"
    }
    
    var searchPlaceholder: String {
        "Введите название станции"
    }
    
    var notFoundText: String {
        if isLoading {
            return "Загрузка станций..."
        }
        
        if let error = errorMessage {
            return "Ошибка: \(error)"
        }
        
        if allStations.isEmpty && !isLoading {
            return "Станции не найдены для города \(city)"
        }
        
        if !searchText.isEmpty && filteredStations.isEmpty {
            return "Станция '\(searchText)' не найдена"
        }
        
        return "Выберите станцию"
    }
    
    // MARK: - Initialization
    init(city: String, initialStation: String, context: AppRoute.CitySearchContext) {
        self.city = city
        self.initialStation = initialStation
        self.context = context
        self.searchText = initialStation
    }
    
    // MARK: - Methods
    @MainActor
    func loadStations() async {
        // Проверяем, если уже загружено, не загружаем снова
        if !allStations.isEmpty && !searchText.isEmpty && !filteredStations.isEmpty {
            isLoading = false
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Используем shared сервис
            let stationNames = try await StationService.shared.getStationsByCity(city, cached: true)
            
            // Преобразуем в StationItem с уникальными ID
            allStations = stationNames.enumerated().map { index, name in
                StationItem(name: name, originalIndex: index)
            }
            
            print("✅ Загружено \(allStations.count) станций для города: \(city)")
            
            if allStations.isEmpty {
                print("⚠️ Не найдено станций для города: \(city)")
            }
        } catch {
            errorMessage = "Не удалось загрузить станции"
            print("❌ Ошибка загрузки станций: \(error)")
            
            // Тестовые данные тоже нужно преобразовать
            let testStations = [
                "Киевский вокзал",
                "Курский вокзал",
                "Ярославский вокзал",
                "Белорусский вокзал",
                "Савеловский вокзал",
                "Ленинградский вокзал"
            ]
            
            allStations = testStations.enumerated().map { index, name in
                StationItem(name: name, originalIndex: index)
            }
        }
        
        isLoading = false
    }
    
    func selectStation(_ station: String) -> String {
        let result: String
        if station.contains(city) {
            result = station
        } else {
            result = "\(city) (\(station))"
        }
        
        return result
    }
    
    func clearSearch() {
        searchText = ""
    }
}
