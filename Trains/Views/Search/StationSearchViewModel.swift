//
//  StationSearchViewModel.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 12.01.2026.
//

import SwiftUI

@Observable
final class StationSearchViewModel {
    // MARK: - Properties
    let city: String
    let initialStation: String
    let context: AppRoute.CitySearchContext
    
    var searchText: String = ""
    
    // MARK: - Mock Data (изолируем от View)
    private let stations = [
        "Киевский вокзал",
        "Курский вокзал",
        "Ярославский вокзал",
        "Белорусский вокзал",
        "Савеловский вокзал",
        "Ленинградский вокзал"
    ]
    
    // MARK: - Computed Properties
    var filteredStations: [String] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty
        ? stations
        : stations.filter { $0.localizedCaseInsensitiveContains(query) }
    }
    
    var navigationTitle: String {
        "Станции в \(city)"
    }
    
    var searchPlaceholder: String {
        "Введите запрос"
    }
    
    var notFoundText: String {
        "Станция не найдена"
    }
    
    // MARK: - Initialization
    init(city: String, initialStation: String, context: AppRoute.CitySearchContext) {
        self.city = city
        self.initialStation = initialStation
        self.context = context
        self.searchText = initialStation
    }
    
    // MARK: - Methods
    func selectStation(_ station: String) -> String {
        "\(city) (\(station))"
    }
    
    func clearSearch() {
        searchText = ""
    }
}
