//
//  NetworkClient.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 13.01.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

actor NetworkClient {
    private let client: Client
    private let apikey: String
    
    // MARK: - Кэширование
    private var citiesCache: [String]?
    private var stationsCache: [String: [String]] = [:] // [город: [станции]]
    private var lastUpdate: Date?
    private let cacheTTL: TimeInterval = 3600 // 1 час
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    // MARK: - Кэшированные методы
    
    func getAllCities(cached: Bool = true) async throws -> [String] {
        if cached, let cachedCities = citiesCache, !isCacheExpired() {
            print("✅ Используем кэш городов (\(cachedCities.count) городов)")
            return cachedCities
        }
        
        print("🔄 Загружаем города из сети...")
        let response = try await getStations()
        let cities = extractCities(from: response)
        
        // Кэшируем
        citiesCache = cities
        lastUpdate = Date()
        
        print("✅ Загружено \(cities.count) городов, сохранено в кэш")
        return cities
    }
    
    func getStationsByCity(_ cityName: String, cached: Bool = true) async throws -> [String] {
        if cached, let cachedStations = stationsCache[cityName], !isCacheExpired() {
            print("✅ Используем кэш станций для \(cityName) (\(cachedStations.count) станций)")
            return cachedStations
        }
        
        // Если нужно загрузить станции для города, загружаем все данные
        print("🔄 Загружаем станции для \(cityName) из сети...")
        let response = try await getStations()
        
        // Извлекаем ВСЕ города и станции
        let allData = extractAllCitiesWithStations(from: response)
        
        // Сохраняем все в кэш
        citiesCache = allData.map { $0.key }
        for (city, stations) in allData {
            stationsCache[city] = stations
        }
        lastUpdate = Date()
        
        // Возвращаем станции для запрошенного города
        let stations = allData[cityName] ?? []
        print("✅ Загружено \(stations.count) станций для \(cityName)")
        return stations
    }
    
    // MARK: - Проверка кэша
    private func isCacheExpired() -> Bool {
        guard let lastUpdate = lastUpdate else { return true }
        return Date().timeIntervalSince(lastUpdate) > cacheTTL
    }
    
    private func extractCities(from response: getStationsResponse) -> [String] {
        var cities = Set<String>()
        
        guard let countries = response.countries else { return [] }
        
        for country in countries {
            guard let regions = country.regions else { continue }
            
            for region in regions {
                guard let settlements = region.settlements else { continue }
                
                for settlement in settlements {
                    // Фильтруем пустые названия городов
                    guard let title = settlement.title,
                          !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        continue
                    }
                    cities.insert(title)
                }
            }
        }
        
        return Array(cities).sorted()
    }
    
    private func extractAllCitiesWithStations(from response: getStationsResponse) -> [String: [String]] {
        var result: [String: [String]] = [:]
        
        guard let countries = response.countries else { return result }
        
        for country in countries {
            guard let regions = country.regions else { continue }
            
            for region in regions {
                guard let settlements = region.settlements else { continue }
                
                for settlement in settlements {
                    // Фильтруем пустые названия городов
                    guard let cityName = settlement.title,
                          !cityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        continue
                    }
                    
                    var stations: [String] = []
                    if let settlementStations = settlement.stations {
                        for station in settlementStations {
                            let stationTitle = getStationTitle(from: station)
                            // Фильтруем пустые названия станций
                            if !stationTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                stations.append(stationTitle)
                            }
                        }
                    }
                    
                    result[cityName] = stations
                }
            }
        }
        
        return result
    }
    
    private func getStationTitle(from station: Components.Schemas.Station) -> String {
        if let popularTitle = station.popular_title, !popularTitle.isEmpty {
            return popularTitle
        }
        
        if let shortTitle = station.short_title, !shortTitle.isEmpty {
            return shortTitle
        }
        
        if let title = station.title, !title.isEmpty {
            return title
        }
        
        return "Неизвестная станция"
    }
    
    // MARK: - Очистка кэша
    func clearCache() {
        citiesCache = nil
        stationsCache.removeAll()
        lastUpdate = nil
        print("🧹 Кэш очищен")
    }
    
    // MARK: - Nearest Stations
    
    func getNearestStations(lat: Double, lng: Double, distance: Int = 50) async throws -> Components.Schemas.Stations {
        let response = try await client.getNearestStations(query: .init(
            apikey: apikey,
            lat: lat,
            lng: lng,
            distance: distance,
            format: "json",
            lang: "ru_RU"
        ))
        return try await response.ok.body.json
    }
    
    // MARK: - Copyright
    
    func getCopyright() async throws -> Components.Schemas.Copyright {
        let response = try await client.getCopyright(query: .init(
            apikey: apikey,
            format: .json
        ))
        return try await response.ok.body.json
    }
    
    // MARK: - Search
    
    func search(
        from: String,
        to: String,
        date: String? = nil,
        transportTypes: String? = nil,
        limit: Int? = 100
    ) async throws -> Components.Schemas.SearchResponse {
        let response = try await client.getSearch(query: .init(
            apikey: apikey,
            from: from,
            to: to,
            format: "json",
            lang: "ru_RU",
            date: date,
            transport_types: transportTypes,
            limit: limit
        ))
        return try await response.ok.body.json
    }
    
    // MARK: - Schedule
    
    func getSchedule(
        station: String,
        date: String? = nil,
        transportTypes: String? = nil,
        event: String? = nil
    ) async throws -> Components.Schemas.ScheduleResponse {
        let response = try await client.getSchedule(query: .init(
            apikey: apikey,
            station: station,
            lang: "ru_RU",
            format: "json",
            date: date,
            transport_types: transportTypes,
            event: event
        ))
        return try await response.ok.body.json
    }
    
    // MARK: - Thread
    
    func getThread(
        uid: String,
        from: String? = nil,
        to: String? = nil,
        date: String? = nil
    ) async throws -> Components.Schemas.ThreadResponse {
        let response = try await client.getThread(query: .init(
            apikey: apikey,
            uid: uid,
            from: from,
            to: to,
            format: "json",
            lang: "ru_RU",
            date: date
        ))
        return try await response.ok.body.json
    }
    
    // MARK: - Nearest Settlement
    
    func getNearestSettlement(
        lat: Double,
        lng: Double,
        distance: Int? = 50
    ) async throws -> Components.Schemas.NearestSettlement {
        let response = try await client.getNearestSettlement(query: .init(
            apikey: apikey,
            lat: lat,
            lng: lng,
            distance: distance,
            lang: "ru_RU",
            format: "json"
        ))
        return try await response.ok.body.json
    }
    
    // MARK: - Carrier
    
    func getCarrier(
        code: String,
        system: Operations.getCarrier.Input.Query.systemPayload? = nil
    ) async throws -> Components.Schemas.CarrierResponse {
        // Определяем system
        let determinedSystem: Operations.getCarrier.Input.Query.systemPayload?
        
        if let system = system {
            // Если система указана явно, используем её
            determinedSystem = system
        } else {
            // Автоматически определяем систему по формату кода
            if code.rangeOfCharacter(from: .letters) != nil {
                determinedSystem = .iata
            } else {
                determinedSystem = nil
            }
        }
        
        let response = try await client.getCarrier(query: .init(
            apikey: apikey,
            code: code,
            format: "json",
            lang: "ru_RU",
            system: determinedSystem
        ))
        return try await response.ok.body.json
    }
    
    // MARK: - Stations List
    
    func getStations() async throws -> getStationsResponse {
        let response = try await client.getStations(query: .init(
            apikey: apikey,
            format: nil,
            lang: nil
        ))
        
        let responseBody = try await response.ok.body.html
        
        let limit = 50 * 1024 * 1024 // 50Mb
        
        let fullData = try await Data(collecting: responseBody, upTo: limit)
        
        // Вызываем MainActor функцию для декодирования
        return try await MainActor.run {
            try JSONDecoder().decode(getStationsResponse.self, from: fullData)
        }
    }
}
