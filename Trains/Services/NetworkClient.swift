// NetworkClient.swift
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
        print("🏙️ Запрос списка городов (кеширование: \(cached))")
        
        if cached, let cachedCities = citiesCache, !isCacheExpired() {
            print("📦 Используем кэшированные города: \(cachedCities.count) городов")
            return cachedCities
        }
        
        print("🌐 Загружаем города из сети...")
        let response = try await getStations()
        let cities = extractCities(from: response)
        
        citiesCache = cities
        lastUpdate = Date()
        
        print("✅ Города загружены: \(cities.count) городов")
        return cities
    }
    
    func getStationsByCity(_ cityName: String, cached: Bool = true) async throws -> [String] {
        print("🚉 Запрос станций для города '\(cityName)' (кеширование: \(cached))")
        
        if cached, let cachedStations = stationsCache[cityName], !isCacheExpired() {
            print("📦 Используем кэшированные станции: \(cachedStations.count) станций")
            return cachedStations
        }
        
        print("🌐 Загружаем станции из сети...")
        let response = try await getStations()
        let allData = extractAllCitiesWithStations(from: response)
        
        citiesCache = allData.map { $0.key }
        for (city, stations) in allData {
            stationsCache[city] = stations
        }
        lastUpdate = Date()
        
        let stations = allData[cityName] ?? []
        print("✅ Станции загружены: \(stations.count) станций для '\(cityName)'")
        return stations
    }
    
    private func isCacheExpired() -> Bool {
        guard let lastUpdate = lastUpdate else {
            print("⏰ Кэш не существует")
            return true
        }
        
        let isExpired = Date().timeIntervalSince(lastUpdate) > cacheTTL
        print("⏰ Проверка кэша: \(isExpired ? "истек" : "актуален")")
        return isExpired
    }
    
    private func extractCities(from response: getStationsResponse) -> [String] {
        print("🔍 Извлекаем города из ответа")
        var cities = Set<String>()
        
        guard let countries = response.countries else {
            print("⚠️ В ответе нет стран")
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
        
        let result = Array(cities).sorted()
        print("✅ Извлечено \(result.count) городов")
        return result
    }
    
    private func extractAllCitiesWithStations(from response: getStationsResponse) -> [String: [String]] {
        print("🔍 Извлекаем города и станции из ответа")
        var result: [String: [String]] = [:]
        
        guard let countries = response.countries else {
            print("⚠️ В ответе нет стран")
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
                                // Добавляем только название станции, без кода в названии
                                stations.append(stationTitle)
                            }
                        }
                    }
                    
                    result[cityName] = stations
                }
            }
        }
        
        print("✅ Извлечено \(result.count) городов со станциями")
        return result
    }
    
    private func getStationTitle(from station: Components.Schemas.Station) -> String {
        // Отдаем приоритет popular_title
        if let popularTitle = station.popular_title, !popularTitle.isEmpty {
            return popularTitle
        }
        
        // Затем short_title
        if let shortTitle = station.short_title, !shortTitle.isEmpty {
            return shortTitle
        }
        
        // И только потом обычный title
        if let title = station.title, !title.isEmpty {
            return title
        }
        
        return "Неизвестная станция"
    }
    
    private func getStationYandexCode(from station: Components.Schemas.Station) -> String? {
        return station.codes?.yandex
    }
    
    func clearCache() {
        print("🗑️ Очистка кэша")
        citiesCache = nil
        stationsCache.removeAll()
        lastUpdate = nil
    }
    
    // MARK: - Получение ID станций и городов
    
    func getStationID(cityName: String, stationName: String) async throws -> String? {
        print("🔍 Поиск ID станции: город='\(cityName)', станция='\(stationName)'")
        
        let response = try await getStations()
        
        guard let countries = response.countries else {
            print("⚠️ В ответе нет стран")
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
                            
                            // Ищем по названию станции (без кода в скобках)
                            let cleanStationName = stationName.components(separatedBy: "(").first?.trimmingCharacters(in: .whitespaces) ?? stationName
                            let cleanStationTitle = stationTitle.components(separatedBy: "(").first?.trimmingCharacters(in: .whitespaces) ?? stationTitle
                            
                            if cleanStationTitle == cleanStationName {
                                if let yandexCode = station.codes?.yandex {
                                    print("✅ Найден Yandex ID станции: \(yandexCode)")
                                    return yandexCode
                                }
                            }
                        }
                    }
                }
            }
        }
        
        print("⚠️ Станция не найдена: \(stationName) в городе \(cityName)")
        return nil
    }
    
    func getCityID(cityName: String) async throws -> String? {
        print("🔍 Поиск ID города: '\(cityName)'")
        
        let response = try await getStations()
        
        guard let countries = response.countries else {
            print("⚠️ В ответе нет стран")
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
                        // Для городов используем код без префикса "c"
                        print("✅ Найден ID города: \(settlementCode)")
                        return settlementCode
                    }
                }
            }
        }
        
        print("⚠️ Город не найден: \(cityName)")
        return nil
    }
    
    // MARK: - Получение данных для поиска
    
    func getSearchData(from formattedFromText: String, to formattedToText: String) async throws -> (fromCode: String, toCode: String) {
        print("🎯 Получение данных для поиска:")
        print("   Откуда: \(formattedFromText)")
        print("   Куда: \(formattedToText)")
        
        let fromData = parseFormattedText(formattedFromText)
        let toData = parseFormattedText(formattedToText)
        
        var fromCode: String
        var toCode: String
        
        print("📝 Анализ точки отправления:")
        print("   Город: \(fromData.cityName)")
        print("   Станция: \(fromData.stationName ?? "не указана")")
        
        // Сначала пробуем найти ID станции
        if let stationName = fromData.stationName {
            if let stationCode = try await getStationID(cityName: fromData.cityName, stationName: stationName) {
                fromCode = stationCode
                print("   ✅ Используем ID станции: \(stationCode)")
            } else if let cityCode = try await getCityID(cityName: fromData.cityName) {
                // Если станцию не нашли, используем код города
                fromCode = cityCode
                print("   ⚠️ Станция не найдена, используем ID города: \(cityCode)")
            } else {
                // Если и город не найден, используем как есть
                fromCode = fromData.cityName
                print("   ❌ Ничего не найдено, используем название: \(fromData.cityName)")
            }
        } else {
            // Если не указана станция, используем код города
            if let cityCode = try await getCityID(cityName: fromData.cityName) {
                fromCode = cityCode
                print("   ✅ Используем ID города: \(cityCode)")
            } else {
                fromCode = fromData.cityName
                print("   ❌ Город не найден, используем название: \(fromData.cityName)")
            }
        }
        
        print("📝 Анализ точки назначения:")
        print("   Город: \(toData.cityName)")
        print("   Станция: \(toData.stationName ?? "не указана")")
        
        if let stationName = toData.stationName {
            if let stationCode = try await getStationID(cityName: toData.cityName, stationName: stationName) {
                toCode = stationCode
                print("   ✅ Используем ID станции: \(stationCode)")
            } else if let cityCode = try await getCityID(cityName: toData.cityName) {
                toCode = cityCode
                print("   ⚠️ Станция не найдена, используем ID города: \(cityCode)")
            } else {
                toCode = toData.cityName
                print("   ❌ Ничего не найдено, используем название: \(toData.cityName)")
            }
        } else {
            if let cityCode = try await getCityID(cityName: toData.cityName) {
                toCode = cityCode
                print("   ✅ Используем ID города: \(cityCode)")
            } else {
                toCode = toData.cityName
                print("   ❌ Город не найден, используем название: \(toData.cityName)")
            }
        }
        
        print("✅ Итоговые коды:")
        print("   From: \(fromCode)")
        print("   To: \(toCode)")
        
        return (fromCode, toCode)
    }
    
    private func parseFormattedText(_ text: String) -> (cityName: String, stationName: String?) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("📝 Парсинг текста: '\(trimmedText)'")
        
        // Убираем "(без кода)" если оно есть
        let cleanedText = trimmedText.replacingOccurrences(of: " \\(без кода\\)", with: "")
            .replacingOccurrences(of: "(без кода)", with: "")
        
        // Проверяем формат "Город (Станция)"
        if !cleanedText.contains("(") || !cleanedText.contains(")") {
            print("   Результат: только город='\(cleanedText)'")
            return (cleanedText, nil)
        }
        
        if let openBracket = cleanedText.firstIndex(of: "("),
           let closeBracket = cleanedText.lastIndex(of: ")") {
            
            let city = String(cleanedText[..<openBracket]).trimmingCharacters(in: .whitespacesAndNewlines)
            let station = String(cleanedText[cleanedText.index(after: openBracket)..<closeBracket])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            print("   Результат: город='\(city)', станция='\(station)'")
            return (city, station.isEmpty ? nil : station)
        }
        
        print("   Результат: только город='\(cleanedText)'")
        return (cleanedText, nil)
    }

    
    // MARK: - API Methods
    
    func search(
        from: String,
        to: String,
        date: String? = nil,
        transportTypes: String? = nil,
        limit: Int? = 20
    ) async throws -> Components.Schemas.SearchResponse {
        print("🔍 Поиск маршрутов:")
        print("   From: \(from)")
        print("   To: \(to)")
        print("   Date: \(date ?? "не указана")")
        print("   Transport Types: \(transportTypes ?? "не указаны")")
        print("   Limit: \(limit ?? 20)")
        print("   API Key: \(apikey.prefix(5))...")
        
        do {
            // Проверяем параметры перед запросом
            guard !from.isEmpty, !to.isEmpty else {
                print("❌ Ошибка: параметры from и to не могут быть пустыми")
                throw URLError(.badURL)
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let currentDate = dateFormatter.string(from: Date())
            
            print("🌐 Выполняем запрос к API...")
            
            let response = try await client.getSearch(query: .init(
                apikey: apikey,
                from: from,
                to: to,
                format: "json",
                lang: "ru_RU",
                date: date ?? currentDate, // Используем текущую дату если не указана
                transport_types: transportTypes,
                limit: limit
            ))
            
            print("✅ Поиск выполнен успешно, код ответа: OK")
            let result = try await response.ok.body.json
            print("📊 Получено сегментов: \(result.segments?.count ?? 0)")
            return result
            
        } catch let error as URLError {
            print("❌ Ошибка URL: \(error.code.rawValue) - \(error.localizedDescription)")
            throw error
        } catch let error as DecodingError {
            print("❌ Ошибка декодирования: \(error)")
            throw error
        } catch {
            print("❌ Неизвестная ошибка поиска: \(error)")
            
            // Пробуем альтернативный подход - поиск между городами
            print("🔄 Пробуем альтернативный поиск...")
            return try await alternativeSearch(from: from, to: to, date: date ?? "")
        }
    }
    
    private func alternativeSearch(from: String, to: String, date: String) async throws -> Components.Schemas.SearchResponse {
        print("🔄 Альтернативный поиск через города")
        
        // Формируем URL напрямую
        var urlComponents = URLComponents(string: "https://api.rasp.yandex.net/v3.0/search/")
        urlComponents?.queryItems = [
            URLQueryItem(name: "apikey", value: apikey),
            URLQueryItem(name: "from", value: from),
            URLQueryItem(name: "to", value: to),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "lang", value: "ru_RU"),
            URLQueryItem(name: "date", value: date),
            URLQueryItem(name: "transport_types", value: "train,bus,plane"),
            URLQueryItem(name: "limit", value: "20")
        ]
        
        guard let url = urlComponents?.url else {
            print("❌ Не удалось создать URL")
            throw URLError(.badURL)
        }
        
        print("🌐 URL запроса: \(url.absoluteString)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Неверный ответ от сервера")
            throw URLError(.badServerResponse)
        }
        
        print("📡 Код ответа: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            print("❌ Ошибка HTTP: \(httpResponse.statusCode)")
            let responseText = String(data: data, encoding: .utf8) ?? "Нет данных"
            print("📄 Тело ответа: \(responseText)")
            throw URLError(.badServerResponse)
        }
        
        print("✅ Данные получены успешно")
        
        // Парсим ответ вручную
        let decoder = JSONDecoder()
        let result = try decoder.decode(Components.Schemas.SearchResponse.self, from: data)
        print("📊 Распарсено сегментов: \(result.segments?.count ?? 0)")
        
        return result
    }
    
    func getSchedule(
        station: String,
        date: String? = nil,
        transportTypes: String? = nil,
        event: String? = nil
    ) async throws -> Components.Schemas.ScheduleResponse {
        print("📅 Запрос расписания для станции: \(station)")
        
        do {
            let response = try await client.getSchedule(query: .init(
                apikey: apikey,
                station: station,
                lang: "ru_RU",
                format: "json",
                date: date,
                transport_types: transportTypes,
                event: event
            ))
            
            print("✅ Расписание получено")
            return try await response.ok.body.json
        } catch {
            print("❌ Ошибка получения расписания: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getThread(
        uid: String,
        from: String? = nil,
        to: String? = nil,
        date: String? = nil
    ) async throws -> Components.Schemas.ThreadResponse {
        print("🧵 Запрос информации о нитке маршрута: \(uid)")
        
        do {
            let response = try await client.getThread(query: .init(
                apikey: apikey,
                uid: uid,
                from: from,
                to: to,
                format: "json",
                lang: "ru_RU",
                date: date
            ))
            
            print("✅ Информация о нитке получена")
            return try await response.ok.body.json
        } catch {
            print("❌ Ошибка получения информации о нитке: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getCarrier(
        code: String,
        system: Operations.getCarrier.Input.Query.systemPayload? = nil
    ) async throws -> Components.Schemas.CarrierResponse {
        print("🚌 Запрос информации о перевозчике: \(code)")
        
        let determinedSystem: Operations.getCarrier.Input.Query.systemPayload?
        
        if let system = system {
            determinedSystem = system
        } else {
            if code.rangeOfCharacter(from: .letters) != nil {
                determinedSystem = .iata
                print("   Определена система: IATA")
            } else {
                determinedSystem = nil
                print("   Система не определена")
            }
        }
        
        do {
            let response = try await client.getCarrier(query: .init(
                apikey: apikey,
                code: code,
                format: "json",
                lang: "ru_RU",
                system: determinedSystem
            ))
            
            print("✅ Информация о перевозчике получена")
            return try await response.ok.body.json
        } catch {
            print("❌ Ошибка получения информации о перевозчике: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getStations() async throws -> getStationsResponse {
        print("🌐 Запрос списка станций")
        
        do {
            let response = try await client.getStations(query: .init(
                apikey: apikey,
                format: nil,
                lang: nil
            ))
            
            let responseBody = try await response.ok.body.html
            
            let limit = 50 * 1024 * 1024
            
            let fullData = try await Data(collecting: responseBody, upTo: limit)
            
            print("✅ Список станций получен, размер данных: \(fullData.count) байт")
            
            return try await MainActor.run {
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(getStationsResponse.self, from: fullData)
                    print("✅ Декодирование успешно, стран: \(result.countries?.count ?? 0)")
                    return result
                } catch {
                    print("❌ Ошибка декодирования: \(error)")
                    // Пробуем сохранить данные для анализа
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let filePath = documentsPath.appendingPathComponent("stations_response.json")
                    try? fullData.write(to: filePath)
                    print("💾 Данные сохранены в: \(filePath.path)")
                    throw error
                }
            }
        } catch {
            print("❌ Ошибка получения списка станций: \(error.localizedDescription)")
            throw error
        }
    }
}
