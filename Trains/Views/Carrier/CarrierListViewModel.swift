//
//  CarrierListViewModel.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 12.01.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class CarrierListViewModel {
    
    // MARK: - Properties
    
    var carriers: [CarrierRowViewModel] = []
    var isLoading = false
    var showEmptyState = false
    var errorMessage: String?
    
    // Состояние фильтра
    private var currentFilter: ScheduleFilter = .default
    
    private let networkClient: NetworkClient
    private let fromText: String
    private let toText: String
    
    // MARK: - Кэширование
    
    // Статический кэш для всех экземпляров
    private static var routeCache: [String: [CarrierRowViewModel]] = [:]
    private static var cacheTimestamp: [String: Date] = [:]
    private let cacheTTL: TimeInterval = 300 // 5 минут
    
    // Ключ для кэша
    private var cacheKey: String {
        "\(cleanStationText(fromText))|\(cleanStationText(toText))|\(currentFilter.selectedTransportTypes.hashValue)"
    }
    
    // Флаг, были ли уже загружены данные
    private var hasLoadedData = false
    
    // MARK: - Computed Properties
    
    var headerTitle: String {
        let cleanFrom = cleanStationText(fromText)
        let cleanTo = cleanStationText(toText)
        return "\(cleanFrom) → \(cleanTo)"
    }
    
    var hasActiveFilter: Bool {
        currentFilter.isActive
    }
    
    var filteredCarriers: [CarrierRowViewModel] {
        if currentFilter.isActive {
            return carriers.filter { carrier in
                // Фильтр по времени отправления
                let timeFilterPassed = filterByTime(carrier.departTime)
                
                // Фильтр по пересадкам
                let transferFilterPassed = filterByTransfers(carrier.note)
                
                // Фильтр по типу транспорта
                let transportTypeFilterPassed = filterByTransportType(carrier.transportType)
                
                return timeFilterPassed && transferFilterPassed && transportTypeFilterPassed
            }
        } else {
            return carriers
        }
    }
    
    var displayCarriers: [CarrierRowViewModel] {
        hasActiveFilter ? filteredCarriers : carriers
    }
    
    // MARK: - Initialization
    
    init(
        fromText: String,
        toText: String,
        networkClient: NetworkClient,
        hasLoadedData: Bool = false // Добавьте этот параметр
    ) {
        self.fromText = fromText
        self.toText = toText
        self.networkClient = networkClient
        self.hasLoadedData = hasLoadedData
    }
    
    // MARK: - Public Methods
    
    func loadCarriers(forceRefresh: Bool = false) async {
        // Проверяем кэш, если не принудительное обновление
        if !forceRefresh && hasLoadedData {
            print("📋 Данные уже загружены, пропускаем")
            isLoading = false
            updateEmptyState()
            return
        }
        
        // Пробуем загрузить из кэша
        if !forceRefresh, let cachedCarriers = Self.routeCache[cacheKey], !isCacheExpired() {
            print("📦 Загружаем из кэша, элементов: \(cachedCarriers.count)")
            self.carriers = cachedCarriers
            self.hasLoadedData = true
            self.isLoading = false
            updateEmptyState()
            return
        }
        
        // Если нет в кэше или кэш устарел, загружаем из сети
        await loadFromNetwork()
    }
    
    private func loadFromNetwork() async {
        isLoading = true
        errorMessage = nil
        
        // Очищаем только если это не кэшированные данные
        if !hasLoadedData {
            carriers = []
        }
        
        do {
            print("🚀 Начинаем загрузку маршрутов из: \(fromText) в: \(toText)")
            
            let (fromCode, toCode) = try await networkClient.getSearchData(
                from: fromText,
                to: toText
            )
            
            print("✅ Получены коды станций: from=\(fromCode), to=\(toCode)")
            
            // Используем фильтр по типам транспорта если есть
            let transportTypes = getTransportTypesString()
            if let transportTypes = transportTypes {
                print("🚌 Используем фильтр типов транспорта: \(transportTypes)")
            }
            
            let response = try await networkClient.search(
                from: fromCode,
                to: toCode,
                date: nil,
                transportTypes: transportTypes,
                limit: 20
            )
            
            print("✅ Получен ответ поиска, количество сегментов: \(response.segments?.count ?? 0)")
            
            await processSearchResponse(response)
            
            // Сохраняем в кэш
            saveToCache(carriers)
            hasLoadedData = true
            
        } catch let error as URLError {
            switch error.code {
            case .badServerResponse:
                print("❌ Ошибка сервера: маршруты не найдены между выбранными пунктами")
                errorMessage = "Маршруты не найдены между выбранными пунктами"
            case .timedOut:
                print("❌ Таймаут соединения")
                errorMessage = "Таймаут соединения, проверьте интернет"
            case .notConnectedToInternet:
                print("❌ Нет соединения с интернетом")
                errorMessage = "Нет соединения с интернетом"
            default:
                print("❌ Ошибка сети: \(error.localizedDescription)")
                errorMessage = "Ошибка сети: \(error.localizedDescription)"
            }
            showEmptyState = true
        } catch let error as DecodingError {
            print("❌ Ошибка декодирования данных: \(error)")
            errorMessage = "Ошибка обработки данных от сервера"
            showEmptyState = true
        } catch {
            print("❌ Общая ошибка загрузки данных: \(error)")
            errorMessage = "Ошибка загрузки данных: \(error.localizedDescription)"
            showEmptyState = true
        }
        
        isLoading = false
        updateEmptyState()
        print("✅ Загрузка завершена. Показано маршрутов: \(displayCarriers.count)")
    }
    
    func applySavedFilter() {
        print("🔍 Применяем сохраненный фильтр")
        // Загружаем сохраненный фильтр
        self.currentFilter = ScheduleFilterViewModel.savedFilter
        
        // Очищаем кэш для этого ключа, так как фильтр изменился
        Self.routeCache.removeValue(forKey: cacheKey)
        Self.cacheTimestamp.removeValue(forKey: cacheKey)
        
        updateEmptyState()
    }
    
    func reloadWithCurrentFilter() {
        print("🔄 Перезагружаем данные с текущим фильтром (принудительно)")
        Task {
            await loadCarriers(forceRefresh: true)
        }
    }
    
    func getCarrierInfo(for index: Int) -> (code: String, logoName: String?)? {
        let targetCarriers = displayCarriers
        guard index >= 0 && index < targetCarriers.count else { return nil }
        let carrier = targetCarriers[index]
        
        guard let code = carrier.carrierCode else {
            return nil
        }
        
        return (code, carrier.logoAssetName)
    }
    
    // MARK: - Кэширование методов
    
    private func saveToCache(_ carriers: [CarrierRowViewModel]) {
        guard !carriers.isEmpty else { return }
        
        print("💾 Сохраняем в кэш, ключ: \(cacheKey), элементов: \(carriers.count)")
        Self.routeCache[cacheKey] = carriers
        Self.cacheTimestamp[cacheKey] = Date()
    }
    
    private func isCacheExpired() -> Bool {
        guard let timestamp = Self.cacheTimestamp[cacheKey] else {
            print("⏰ Кэш не существует для ключа: \(cacheKey)")
            return true
        }
        
        let isExpired = Date().timeIntervalSince(timestamp) > cacheTTL
        print("⏰ Проверка кэша: \(isExpired ? "истек" : "актуален"), возраст: \(Int(Date().timeIntervalSince(timestamp))) секунд")
        return isExpired
    }
    
    // MARK: - Private Methods
    
    private func cleanStationText(_ text: String) -> String {
        var result = text
        
        // Убираем "(без кода)" в разных вариациях
        result = result.replacingOccurrences(of: " \\(без кода\\)", with: "")
        result = result.replacingOccurrences(of: "(без кода)", with: "")
        
        // Убираем лишние пробелы
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return result
    }
    
    private func getTransportTypesString() -> String? {
        // Преобразуем Set<TransportType> в строку для API
        guard !currentFilter.selectedTransportTypes.isEmpty else { return nil }
        
        let transportTypes = currentFilter.selectedTransportTypes.map { $0.rawValue }
        return transportTypes.joined(separator: ",")
    }
    
    private func processSearchResponse(_ response: Components.Schemas.SearchResponse) async {
        guard let segments = response.segments else {
            print("⚠️ В ответе нет сегментов маршрутов")
            carriers = []
            showEmptyState = true
            return
        }
        
        print("🎯 Обрабатываем \(segments.count) сегментов маршрутов")
        
        var carrierViewModels: [CarrierRowViewModel] = []
        
        for (index, segment) in segments.enumerated() {
            guard let thread = segment.thread,
                  let departure = segment.departure,
                  let arrival = segment.arrival else {
                print("⚠️ Пропускаем сегмент \(index): отсутствуют обязательные данные")
                continue
            }
            
            let carrierName = thread.carrier?.title ?? "Неизвестный перевозчик"
            let carrierCode = thread.carrier?.code.flatMap { String($0) }
            let carrierLogo = thread.carrier?.logo
            
            let departTime = formatTime(from: departure)
            let arriveTime = formatTime(from: arrival)
            let durationSeconds = Int(segment.duration ?? 0.0)
            let durationText = formatDuration(durationSeconds)
            let dateText = formatDate(from: departure)
            
            let note = extractTransferInfo(from: segment)
            let transportType = thread.transport_type ?? "train" // Значение по умолчанию
            
            let viewModel = CarrierRowViewModel(
                carrierName: carrierName,
                logoURL: carrierLogo,
                transportType: transportType,
                carrierCode: carrierCode,
                dateText: dateText,
                departTime: departTime,
                arriveTime: arriveTime,
                durationText: durationText,
                note: note
            )
            
            carrierViewModels.append(viewModel)
            
            print("✅ Добавлен маршрут \(index+1): \(carrierName), \(departTime) → \(arriveTime)")
        }
        
        carriers = carrierViewModels
        updateEmptyState()
    }
    
    private func filterByTime(_ departTime: String) -> Bool {
        guard !currentFilter.selectedDayParts.isEmpty else { return true }
        
        let components = departTime.split(separator: ":")
        guard components.count >= 2,
              let hour = Int(components[0]) else {
            return true
        }
        
        return currentFilter.selectedDayParts.contains { dayPart in
            let range = dayPart.timeRange
            
            if range.start < range.end {
                // Нормальный диапазон (например, 6-12)
                return hour >= range.start && hour < range.end
            } else {
                // Диапазон через полночь (например, 0-6)
                return hour >= range.start || hour < range.end
            }
        }
    }
    
    private func filterByTransfers(_ note: String?) -> Bool {
        guard let showTransfers = currentFilter.showTransfers else {
            // Если фильтр по пересадкам не выбран - показываем все
            return true
        }
        
        if showTransfers {
            // Показываем все, включая с пересадками
            return true
        } else {
            // Показываем только без пересадок
            return note == nil
        }
    }
    
    private func filterByTransportType(_ transportType: String?) -> Bool {
        guard !currentFilter.selectedTransportTypes.isEmpty else { return true }
        
        guard let type = transportType else { return false }
        
        // Проверяем, есть ли выбранный тип в фильтре
        return currentFilter.selectedTransportTypes.contains { filterType in
            filterType.rawValue == type
        }
    }
    
    private func updateEmptyState() {
        showEmptyState = displayCarriers.isEmpty
        if showEmptyState {
            print("📭 Список маршрутов пуст. Показано: 0 элементов")
        }
    }
    
    private func formatTime(from timeString: String) -> String {
        print("🕐 Форматирование времени из строки: \(timeString)")
        
        // Сначала пробуем распарсить как полную дату
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        // Пробуем несколько форматов даты
        let possibleFormats = [
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss",
            "HH:mm:ss",
            "HH:mm"
        ]
        
        for format in possibleFormats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: timeString) {
                // Форматируем в 24-часовой формат
                dateFormatter.dateFormat = "HH:mm"
                let result = dateFormatter.string(from: date)
                print("   ✅ Время форматировано: \(result)")
                return result
            }
        }
        
        // Если не удалось распарсить как дату, извлекаем часы и минуты напрямую
        let pattern = #"(\d{1,2}):(\d{2})"#
        
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: timeString, range: NSRange(timeString.startIndex..., in: timeString)),
           match.numberOfRanges >= 3,
           let hourRange = Range(match.range(at: 1), in: timeString),
           let minuteRange = Range(match.range(at: 2), in: timeString) {
            
            var hour = String(timeString[hourRange])
            let minute = String(timeString[minuteRange])
            
            // Убеждаемся, что час имеет 2 цифры
            if hour.count == 1 { hour = "0\(hour)" }
            
            let result = "\(hour):\(minute)"
            print("   ✅ Время извлечено: \(result)")
            return result
        }
        
        print("   ⚠️ Не удалось форматировать время: \(timeString)")
        return "--:--"
    }
    
    private func formatDate(from timeString: String) -> String {
        print("📅 Форматирование даты из строки: \(timeString)")
        
        // Пытаемся извлечь дату из строки
        let datePattern = #"(\d{4})-(\d{2})-(\d{2})"#
        
        if let regex = try? NSRegularExpression(pattern: datePattern),
           let match = regex.firstMatch(in: timeString, range: NSRange(timeString.startIndex..., in: timeString)),
           match.numberOfRanges >= 4 {
            
            if let yearRange = Range(match.range(at: 1), in: timeString),
               let monthRange = Range(match.range(at: 2), in: timeString),
               let dayRange = Range(match.range(at: 3), in: timeString) {
                
                let year = String(timeString[yearRange])
                let month = String(timeString[monthRange])
                let day = String(timeString[dayRange])
                
                // Форматируем день
                let dayInt = Int(day) ?? 0
                
                // Форматируем месяц
                let monthNames = [
                    "01": "января", "02": "февраля", "03": "марта", "04": "апреля",
                    "05": "мая", "06": "июня", "07": "июля", "08": "августа",
                    "09": "сентября", "10": "октября", "11": "ноября", "12": "декабря"
                ]
                
                let monthName = monthNames[month] ?? "неизвестного"
                
                let result = "\(dayInt) \(monthName)"
                print("   ✅ Дата форматирована: \(result)")
                return result
            }
        }
        
        // Если не удалось извлечь дату, возвращаем текущую дату
        print("   ⚠️ Не удалось извлечь дату, используем текущую")
        return formatCurrentDate()
    }
    
    private func formatCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM"
        
        let dateString = dateFormatter.string(from: Date())
        
        // Корректируем падеж месяцев
        let monthCorrections: [String: String] = [
            "Январь": "января",
            "Февраль": "февраля",
            "Март": "марта",
            "Апрель": "апреля",
            "Май": "мая",
            "Июнь": "июня",
            "Июль": "июля",
            "Август": "августа",
            "Сентябрь": "сентября",
            "Октябрь": "октября",
            "Ноябрь": "ноября",
            "Декабрь": "декабря"
        ]
        
        var result = dateString
        for (incorrect, correct) in monthCorrections {
            result = result.replacingOccurrences(of: incorrect, with: correct)
        }
        
        return result
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours) ч \(minutes) мин"
        } else if hours > 0 {
            return "\(hours) ч"
        } else if minutes > 0 {
            return "\(minutes) мин"
        } else {
            return "менее минуты"
        }
    }
    
    private func extractTransferInfo(from segment: Components.Schemas.Segment) -> String? {
        guard let hasTransfers = segment.has_transfers else {
            return nil
        }
        
        if hasTransfers {
            return "С пересадками"
        } else {
            return nil
        }
    }
    
    // MARK: - Очистка кэша (опционально, для отладки)
    
    static func clearCache() {
        print("🗑️ Очистка кэша маршрутов")
        routeCache.removeAll()
        cacheTimestamp.removeAll()
    }
}
