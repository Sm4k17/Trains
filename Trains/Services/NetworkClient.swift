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
        
        return allData[cityName] ?? []
    }
    
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
                            
                            if stationTitle == stationName {
                                if let codes = station.codes {
                                    if let yandexCode = codes.yandex {
                                        return yandexCode
                                    }
                                }
                                
                                if let settlementCode = settlement.codes?.yandex_code {
                                    return settlementCode
                                }
                                
                                return nil
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
        
        guard let countries = response.countries else { return nil }
        
        for country in countries {
            guard let regions = country.regions else { continue }
            
            for region in regions {
                guard let settlements = region.settlements else { continue }
                
                for settlement in settlements {
                    if let title = settlement.title,
                       title == cityName,
                       let settlementCode = settlement.codes?.yandex_code {
                        return "c\(settlementCode)"
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
        
        if !trimmedText.contains("(") || !trimmedText.contains(")") {
            return (trimmedText, nil)
        }
        
        let pattern = #"^([^\(]+) \(([^\(\)]+(?: \([^\(\)]+\))?)\)$"#
        
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: trimmedText, range: NSRange(trimmedText.startIndex..., in: trimmedText)),
           match.numberOfRanges >= 3,
           let cityRange = Range(match.range(at: 1), in: trimmedText),
           let stationRange = Range(match.range(at: 2), in: trimmedText) {
            
            let city = String(trimmedText[cityRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            var station = String(trimmedText[stationRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            
            if station.hasPrefix(city + " (") && station.last == ")" {
                station = String(station.dropFirst(city.count + 2).dropLast())
            }
            
            return (city, station.isEmpty ? nil : station)
        }
        
        if let openBracket = trimmedText.firstIndex(of: "("),
           let closeBracket = trimmedText.lastIndex(of: ")") {
            
            let city = String(trimmedText[..<openBracket]).trimmingCharacters(in: .whitespacesAndNewlines)
            var station = String(trimmedText[trimmedText.index(after: openBracket)..<closeBracket])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if station.hasPrefix(city + " (") && station.last == ")" {
                let innerStart = station.index(station.startIndex, offsetBy: city.count + 2)
                let innerEnd = station.index(before: station.endIndex)
                station = String(station[innerStart..<innerEnd])
            }
            
            return (city, station.isEmpty ? nil : station)
        }
        
        return (trimmedText, nil)
    }
    
    // MARK: - API Methods
    
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
    
    func getCarrier(
        code: String,
        system: Operations.getCarrier.Input.Query.systemPayload? = nil
    ) async throws -> Components.Schemas.CarrierResponse {
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
        let response = try await client.getStations(query: .init(
            apikey: apikey,
            format: nil,
            lang: nil
        ))
        
        let responseBody = try await response.ok.body.html
        
        let limit = 50 * 1024 * 1024
        
        let fullData = try await Data(collecting: responseBody, upTo: limit)
        
        return try await MainActor.run {
            try JSONDecoder().decode(getStationsResponse.self, from: fullData)
        }
    }
}
