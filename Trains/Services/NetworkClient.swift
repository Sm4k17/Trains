//
//  NetworkClient.swift
//  Trains
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

actor NetworkClient {
    private let client: Client
    private let apikey: String
    
    private var citiesCache: [String]?
    private var stationsCache: [String: [String]] = [:]
    private var lastUpdate: Date?
    private let cacheTTL: TimeInterval = 3600
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    // MARK: - Кэшированные методы
    
    func getAllCities(cached: Bool = true) async throws -> [String] {
        if cached, let cachedCities = citiesCache, !isCacheExpired() {
            return cachedCities
        }
        
        let response = try await getStations()
        let cities = extractCities(from: response)
        
        citiesCache = cities
        lastUpdate = Date()
        
        return cities
    }
    
    func getStationsByCity(_ cityName: String, cached: Bool = true) async throws -> [String] {
        if cached, let cachedStations = stationsCache[cityName], !isCacheExpired() {
            return cachedStations
        }
        
        let response = try await getStations()
        let allData = extractAllCitiesWithStations(from: response)
        
        citiesCache = allData.map { $0.key }
        for (city, stations) in allData {
            stationsCache[city] = stations
        }
        lastUpdate = Date()
        
        let stations = allData[cityName] ?? []
        return stations
    }
    
    private func isCacheExpired() -> Bool {
        guard let lastUpdate = lastUpdate else {
            return true
        }
        
        return Date().timeIntervalSince(lastUpdate) > cacheTTL
    }
    
    private func extractCities(from response: getStationsResponse) -> [String] {
        var cities = Set<String>()
        
        guard let countries = response.countries else {
            return []
        }
        
        for country in countries {
            guard let regions = country.regions else { continue }
            
            for region in regions {
                guard let settlements = region.settlements else { continue }
                
                for settlement in settlements {
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
        
        guard let countries = response.countries else {
            return result
        }
        
        for country in countries {
            guard let regions = country.regions else { continue }
            
            for region in regions {
                guard let settlements = region.settlements else { continue }
                
                for settlement in settlements {
                    guard let cityName = settlement.title,
                          !cityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        continue
                    }
                    
                    var stations: [String] = []
                    if let settlementStations = settlement.stations {
                        for station in settlementStations {
                            let stationTitle = getStationTitle(from: station)
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
    
    func clearCache() {
        citiesCache = nil
        stationsCache.removeAll()
        lastUpdate = nil
    }
    
    // MARK: - Получение ID станций и городов
    
    func getStationID(cityName: String, stationName: String) async throws -> String? {
        let response = try await getStations()
        
        guard let countries = response.countries else {
            return nil
        }
        
        for country in countries {
            guard let regions = country.regions else { continue }
            
            for region in regions {
                guard let settlements = region.settlements else { continue }
                
                for settlement in settlements {
                    guard let settlementTitle = settlement.title,
                          settlementTitle == cityName else {
                        continue
                    }
                    
                    if let stations = settlement.stations {
                        for station in stations {
                            let stationTitle = getStationTitle(from: station)
                            
                            let cleanStationName = stationName.components(separatedBy: "(").first?.trimmingCharacters(in: .whitespaces) ?? stationName
                            let cleanStationTitle = stationTitle.components(separatedBy: "(").first?.trimmingCharacters(in: .whitespaces) ?? stationTitle
                            
                            if cleanStationTitle == cleanStationName {
                                if let yandexCode = station.codes?.yandex {
                                    return yandexCode
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    func getCityID(cityName: String) async throws -> String? {
        let response = try await getStations()
        
        guard let countries = response.countries else {
            return nil
        }
        
        for country in countries {
            guard let regions = country.regions else { continue }
            
            for region in regions {
                guard let settlements = region.settlements else { continue }
                
                for settlement in settlements {
                    if let title = settlement.title,
                       title == cityName,
                       let settlementCode = settlement.codes?.yandex_code {
                        return settlementCode
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Получение данных для поиска
    
    func getSearchData(from formattedFromText: String, to formattedToText: String) async throws -> (fromCode: String, toCode: String) {
        let fromData = parseFormattedText(formattedFromText)
        let toData = parseFormattedText(formattedToText)
        
        var fromCode: String
        var toCode: String
        
        if let stationName = fromData.stationName {
            if let stationCode = try await getStationID(cityName: fromData.cityName, stationName: stationName) {
                fromCode = stationCode
            } else if let cityCode = try await getCityID(cityName: fromData.cityName) {
                fromCode = cityCode
            } else {
                fromCode = fromData.cityName
            }
        } else {
            if let cityCode = try await getCityID(cityName: fromData.cityName) {
                fromCode = cityCode
            } else {
                fromCode = fromData.cityName
            }
        }
        
        if let stationName = toData.stationName {
            if let stationCode = try await getStationID(cityName: toData.cityName, stationName: stationName) {
                toCode = stationCode
            } else if let cityCode = try await getCityID(cityName: toData.cityName) {
                toCode = cityCode
            } else {
                toCode = toData.cityName
            }
        } else {
            if let cityCode = try await getCityID(cityName: toData.cityName) {
                toCode = cityCode
            } else {
                toCode = toData.cityName
            }
        }
        
        return (fromCode, toCode)
    }
    
    private func parseFormattedText(_ text: String) -> (cityName: String, stationName: String?) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let cleanedText = trimmedText.replacingOccurrences(of: " \\(без кода\\)", with: "")
            .replacingOccurrences(of: "(без кода)", with: "")
        
        if !cleanedText.contains("(") || !cleanedText.contains(")") {
            return (cleanedText, nil)
        }
        
        if let openBracket = cleanedText.firstIndex(of: "("),
           let closeBracket = cleanedText.lastIndex(of: ")") {
            
            let city = String(cleanedText[..<openBracket]).trimmingCharacters(in: .whitespacesAndNewlines)
            let station = String(cleanedText[cleanedText.index(after: openBracket)..<closeBracket])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            return (city, station.isEmpty ? nil : station)
        }
        
        return (cleanedText, nil)
    }
    
    // MARK: - API Methods
    
    func search(
        from: String,
        to: String,
        date: String? = nil,
        transportTypes: String? = nil,
        limit: Int = 50
    ) async throws -> Components.Schemas.SearchResponse {
        let response = try await client.getSearch(query: .init(
            apikey: apikey,
            from: from,
            to: to,
            format: "json",
            lang: "ru_RU",
            date: date ?? currentDate(),
            transport_types: transportTypes,
            limit: limit,
            transfers: true
        ))
        
        return try await response.ok.body.json
    }
    
    private func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    func getCarrier(
            code: String,
            system: Operations.getCarrier.Input.Query.systemPayload? = nil
        ) async throws -> Components.Schemas.CarrierResponse {
            // Исправление: Проверяем валидность кода перевозчика
            guard let intCode = Int(code), intCode > 0 else {
                throw NSError(
                    domain: "NetworkClient",
                    code: 400,
                    userInfo: [NSLocalizedDescriptionKey: "Неверный код перевозчика: \(code)"]
                )
            }
            
            let determinedSystem: Operations.getCarrier.Input.Query.systemPayload?
            
            if let system = system {
                determinedSystem = system
            } else {
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
    
    func getStations() async throws -> getStationsResponse {
        do {
            let response = try await client.getStations(query: .init(
                apikey: apikey,
                format: nil,
                lang: nil
            ))
            
            let responseBody = try await response.ok.body.html
            
            let limit = 50 * 1024 * 1024
            
            let fullData = try await Data(collecting: responseBody, upTo: limit)
            
            return try await MainActor.run {
                do {
                    let decoder = JSONDecoder()
                    return try decoder.decode(getStationsResponse.self, from: fullData)
                } catch {
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let filePath = documentsPath.appendingPathComponent("stations_response.json")
                    try? fullData.write(to: filePath)
                    throw error
                }
            }
        }
    }
}
