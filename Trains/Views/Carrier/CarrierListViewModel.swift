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
    
    private var allRoutes: [Route] = [] {
        didSet {
            updateDisplayedCarriers()
        }
    }
    
    private var allCarriers: [CarrierRowViewModel] = []
    
    var carriers: [CarrierRowViewModel] {
        hasActiveFilter ? filteredCarriers : allCarriers
    }
    
    var isLoading = false
    var showEmptyState = false
    var errorMessage: String?
    
    private var currentFilter: ScheduleFilter = .default {
        didSet {
            if oldValue != currentFilter {
                updateDisplayedCarriers()
            }
        }
    }
    
    private let networkClient: NetworkClient
    private let fromText: String
    private let toText: String
    
    // MARK: - Кэширование
    
    private static var routeCache: [String: [Route]] = [:]
    private static var cacheTimestamp: [String: Date] = [:]
    private let cacheTTL: TimeInterval = 300
    
    private var cacheKey: String {
        return "\(fromText)|\(toText)"
    }
    
    private var hasLoadedData = false
    
    // MARK: - Computed Properties
    
    var headerTitle: String {
        return "\(fromText) → \(toText)"
    }
    
    var hasActiveFilter: Bool {
        currentFilter.isActive
    }
    
    var filteredCarriers: [CarrierRowViewModel] {
        var routesToProcess = allRoutes
        
        // Фильтр пересадок
        if let showTransfers = currentFilter.showTransfers {
            routesToProcess = routesToProcess.filter { route in
                if showTransfers {
                    return route.hasTransfers // Показать только с пересадками
                } else {
                    return !route.hasTransfers // Показать только прямые
                }
            }
        }
        
        // Фильтр по времени
        if !currentFilter.selectedDayParts.isEmpty {
            routesToProcess = routesToProcess.filter { route in
                filterByTime(route.departureTime)
            }
        }
        
        // Фильтр по типу транспорта
        if !currentFilter.selectedTransportTypes.isEmpty {
            routesToProcess = routesToProcess.filter { route in
                filterByTransportType(route.transportTypes)
            }
        }
        
        return routesToProcess.map { convertToCarrierRowViewModel($0) }
    }
    
    // MARK: - Initialization
    
    init(
        fromText: String,
        toText: String,
        networkClient: NetworkClient
    ) {
        self.fromText = fromText
        self.toText = toText
        self.networkClient = networkClient
    }
    
    // MARK: - Public Methods
    
    func loadCarriers(forceRefresh: Bool = false) async {
        if !forceRefresh, let cachedRoutes = Self.routeCache[cacheKey], !isCacheExpired() {
            self.allRoutes = cachedRoutes
            self.hasLoadedData = true
            self.isLoading = false
            updateEmptyState()
            return
        }
        
        await loadFromNetwork()
    }
    
    private func loadFromNetwork() async {
        isLoading = true
        errorMessage = nil
        
        if !hasLoadedData {
            allRoutes = []
        }
        
        do {
            let (fromCode, toCode) = try await networkClient.getSearchData(
                from: fromText,
                to: toText
            )
            
            let response = try await networkClient.search(
                from: fromCode,
                to: toCode,
                date: nil,
                transportTypes: nil,
                limit: 50
            )
            
            await processSearchResponse(response)
            
            saveToCache(allRoutes)
            hasLoadedData = true
            
        } catch let error as URLError {
            handleNetworkError(error)
        } catch _ as DecodingError {
            errorMessage = "Ошибка обработки данных"
            showEmptyState = true
        } catch {
            errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
            showEmptyState = true
        }
        
        isLoading = false
        updateEmptyState()
    }
    
    func applySavedFilter() {
        self.currentFilter = ScheduleFilterViewModel.savedFilter
    }
    
    func reloadWithCurrentFilter() {
        Task {
            await loadCarriers(forceRefresh: true)
        }
    }
    
    func getCarrierInfo(for index: Int) -> (code: String, logoName: String?)? {
        let targetCarriers = carriers
        guard index >= 0 && index < targetCarriers.count else { return nil }
        let carrier = targetCarriers[index]
        
        // Исправление: Проверяем валидность кода перевозчика
        guard let code = carrier.carrierCode,
              let intCode = Int(code),
              intCode > 0 else {
            return nil // Не передаем некорректные коды в API
        }
        
        return (code, carrier.logoAssetName)
    }
    
    // MARK: - Private Methods
    
    private func processSearchResponse(_ response: Components.Schemas.SearchResponse) async {
        guard let segments = response.segments else {
            allRoutes = []
            showEmptyState = true
            return
        }
        
    #if DEBUG
        print("=== DEBUG: Получено сегментов от API: \(segments.count)")
    #endif
        
        var routes: [Route] = []
        
        // 1. Сначала собираем все DirectSegment
        var directSegments: [(index: Int, segment: Components.Schemas.DirectSegment)] = []
        var transferSegments: [(index: Int, segment: Components.Schemas.TransferSegment)] = []
        
        for (index, segment) in segments.enumerated() {
            switch segment {
            case .DirectSegment(let direct):
                directSegments.append((index, direct))
            case .TransferSegment(let transfer):
                transferSegments.append((index, transfer))
            }
        }
        
        // 2. Обрабатываем TransferSegment как есть
        for (index, transfer) in transferSegments {
            let route = createTransferRoute(from: transfer, index: index)
            routes.append(route)
        }
        
        // 3. Анализируем DirectSegment и группируем пересадочные
        var groupedTransfers: [Route] = []
        var standaloneDirects: [Route] = []
        
        // Простой алгоритм: если у DirectSegment нет перевозчика или код=0,
        // это часть пересадочного маршрута
        for (index, direct) in directSegments {
            let route = createDirectRoute(from: direct, index: index)
            
            // Проверяем, реальный ли это прямой рейс
            if isRealDirectRoute(direct) {
                standaloneDirects.append(route)
            } else {
                // Это часть пересадочного маршрута
                // Нужно сгруппировать с другими такими же сегментами
                // Пока просто добавляем как отдельный маршрут с пометкой
                let transferRoute = Route(
                    id: "grouped_\(index)_transfer",
                    title: route.title,
                    departureTime: route.departureTime,
                    arrivalTime: route.arrivalTime,
                    duration: route.duration,
                    carriers: route.carriers,
                    transportTypes: route.transportTypes,
                    hasTransfers: true, // <- ОТМЕТКА, ЧТО ЭТО ПЕРЕСАДКА
                    transfersCount: 1,
                    transfers: [],
                    details: [],
                    transferPointName: extractCityFromTitle(route.title)
                )
                groupedTransfers.append(transferRoute)
            }
        }
        
        // 4. Объединяем все маршруты
        routes.append(contentsOf: standaloneDirects)
        routes.append(contentsOf: groupedTransfers)
        
        allRoutes = routes.sorted { $0.departureTime < $1.departureTime }
    }

    private func isRealDirectRoute(_ direct: Components.Schemas.DirectSegment) -> Bool {
        // Реальный прямой рейс имеет:
        // 1. Перевозчика с кодом > 0
        if let carrier = direct.thread?.carrier,
           let code = carrier.code,
           code > 0,
           let title = carrier.title,
           !title.isEmpty {
            return true
        }
        
        // 2. Длительность > 1 часа (реальный маршрут)
        if let duration = direct.duration, duration > 3600 {
            return true
        }
        
        // 3. Есть номер рейса или нормальное название
        if let thread = direct.thread,
           (thread.number != nil ||
            (thread.title?.contains("→") == true ||
             thread.title?.contains("-") == true)) {
            return true
        }
        
        return false
    }

    private func extractCityFromTitle(_ title: String?) -> String? {
        guard let title = title else { return nil }
        
        // Пытаемся извлечь название города из заголовка маршрута
        // Например: "Москва → Кострома" -> "Кострома"
        if let arrowRange = title.range(of: "→") {
            let cityPart = title[arrowRange.upperBound...]
                .trimmingCharacters(in: .whitespaces)
                .split(separator: ",")
                .first?
                .trimmingCharacters(in: .whitespaces)
            
            return cityPart?.isEmpty == false ? String(cityPart!) : nil
        }
        
        return nil
    }
    
    private func createDirectRoute(from direct: Components.Schemas.DirectSegment, index: Int) -> Route {
        let carrier: Components.Schemas.Carrier
        
        if let foundCarrier = direct.thread?.carrier {
            carrier = foundCarrier
        } else if let thread = direct.thread {
            carrier = createSyntheticCarrier(from: thread)
        } else {
            carrier = createUnknownCarrier()
        }
        
        return Route(
            id: "\(index)_direct",
            title: direct.thread?.title ?? "Прямой рейс",
            departureTime: direct.departure ?? "",
            arrivalTime: direct.arrival ?? "",
            duration: Int(direct.duration ?? 0),
            carriers: [carrier],
            transportTypes: [direct.thread?.transport_type ?? "train"],
            hasTransfers: false,
            transfersCount: 0,
            transfers: [],
            details: [],
            transferPointName: nil
        )
    }
    
    private func createTransferRoute(from transfer: Components.Schemas.TransferSegment, index: Int) -> Route {
        let carriers = extractCarriersFromDetails(transfer.details)
        let transportTypes = extractTransportTypesFromDetails(transfer.details)
        
        // Получаем название города пересадки
        let transferPointName = extractTransferCityName(from: transfer)
        
        return Route(
            id: "\(index)_transfer_\(transfer.transfers.count)",
            title: "Маршрут с пересадкой", 
            departureTime: transfer.departure ?? "",
            arrivalTime: transfer.arrival ?? "",
            duration: calculateTotalDuration(transfer.details),
            carriers: carriers.isEmpty ? [createUnknownCarrier()] : carriers,
            transportTypes: transportTypes.isEmpty ? ["train"] : transportTypes,
            hasTransfers: true,
            transfersCount: transfer.transfers.count,
            transfers: transfer.transfers,
            details: extractJourneySegments(from: transfer.details),
            transferPointName: transferPointName // <- добавлена запятая
        )
    }

    // Новый метод для извлечения названия города пересадки
    private func extractTransferCityName(from transfer: Components.Schemas.TransferSegment) -> String? {
        // Ищем в transfers
        if let firstTransfer = transfer.transfers.first {
            // Берем популярное название, обычное или короткое
            return firstTransfer.popular_title ?? firstTransfer.title ?? firstTransfer.short_title
        }
        
        // Или ищем в details (первая промежуточная станция)
        for detail in transfer.details {
            switch detail {
            case .JourneySegment(let journeySegment):
                if let fromTitle = journeySegment.from?.popular_title ?? journeySegment.from?.title ?? journeySegment.from?.short_title {
                    // Пропускаем начальную точку маршрута
                    if fromTitle != transfer.departure_from?.title &&
                       fromTitle != transfer.departure_from?.popular_title &&
                       fromTitle != transfer.departure_from?.short_title {
                        return fromTitle
                    }
                }
            case .TransferStop:
                continue
            }
        }
        
        return nil
    }
    
    private func extractCarriersFromDetails(_ details: [Components.Schemas.TransferSegment.detailsPayloadPayload]?) -> [Components.Schemas.Carrier] {
        guard let details = details else { return [] }
        
        var carriers: [Components.Schemas.Carrier] = []
        
        for detail in details {
            switch detail {
            case .JourneySegment(let journeySegment):
                if let thread = journeySegment.thread {
                    if let carrier = thread.carrier {
                        if !carriers.contains(where: { $0.code == carrier.code }) {
                            carriers.append(carrier)
                        }
                    } else {
                        carriers.append(createSyntheticCarrier(from: thread))
                    }
                }
            case .TransferStop:
                continue
            }
        }
        
        return carriers
    }
    
    private func extractTransportTypesFromDetails(_ details: [Components.Schemas.TransferSegment.detailsPayloadPayload]?) -> [String] {
        guard let details = details else { return ["train"] }
        
        var types: Set<String> = []
        
        for detail in details {
            switch detail {
            case .JourneySegment(let journeySegment):
                if let transportType = journeySegment.thread?.transport_type {
                    types.insert(transportType)
                }
            case .TransferStop:
                continue
            }
        }
        
        return types.isEmpty ? ["train"] : Array(types)
    }
    
    private func calculateTotalDuration(_ details: [Components.Schemas.TransferSegment.detailsPayloadPayload]?) -> Int {
        guard let details = details else { return 0 }
        
        var totalDuration: Double = 0
        
        for detail in details {
            switch detail {
            case .JourneySegment(let journeySegment):
                totalDuration += journeySegment.duration ?? 0
            case .TransferStop(let transferStop):
                totalDuration += transferStop.duration ?? 0
            }
        }
        
        return Int(totalDuration)
    }
    
    private func extractJourneySegments(from detailsPayload: [Components.Schemas.TransferSegment.detailsPayloadPayload]?) -> [Components.Schemas.JourneySegment] {
        guard let detailsPayload = detailsPayload else { return [] }
        
        return detailsPayload.compactMap { detail in
            switch detail {
            case .JourneySegment(let journeySegment):
                return journeySegment
            case .TransferStop:
                return nil
            }
        }
    }
    
    private func createSyntheticCarrier(from thread: Components.Schemas.Thread) -> Components.Schemas.Carrier {
        let code = extractCodeFromUid(thread.uid)
        
        return Components.Schemas.Carrier(
            code: code,
            contacts: nil,
            url: nil,
            title: thread.short_title ?? thread.title, // ФИКС: short_title приоритетнее
            phone: nil,
            codes: Components.Schemas.CarrierCodes(icao: nil, sirena: nil, iata: nil),
            address: nil,
            logo: nil,
            email: nil
        )
    }
    
    private func createUnknownCarrier() -> Components.Schemas.Carrier {
        return Components.Schemas.Carrier(
            code: 0,
            contacts: nil,
            url: nil,
            title: "Неизвестный перевозчик",
            phone: nil,
            codes: Components.Schemas.CarrierCodes(icao: nil, sirena: nil, iata: nil),
            address: nil,
            logo: nil,
            email: nil
        )
    }
    
    private func extractCodeFromUid(_ uid: String?) -> Int? {
        guard let uid = uid else { return nil }
        
        let numericPart = uid.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
        
        if let intCode = Int(numericPart), intCode > 0 {
            return intCode
        }
        
        return nil // Не создаем синтетический код из hash
    }
    
    private func convertToCarrierRowViewModel(_ route: Route) -> CarrierRowViewModel {
        let carrier = route.carriers.first
        let carrierName: String
        let carrierCode: String?
        let logoURL: String?
        
#if DEBUG
    print("=== DEBUG Carrier Info ===")
    print("Carrier title: \(carrier?.title ?? "nil")")
    print("Carrier code: \(carrier?.code ?? -1)")
    print("Has transfers: \(route.hasTransfers)")
    print("Route ID: \(route.id)")
    print("==========================")
#endif
        
        // Общая логика для определения имени перевозчика
        if let carrier = carrier {
            if let title = carrier.title, !title.isEmpty {
                carrierName = title
            } else {
                carrierName = route.hasTransfers ? "Несколько перевозчиков" : "Неизвестный перевозчик"
            }
            
            // Исправление: Проверяем валидность кода
            if let code = carrier.code, code > 0 {
                carrierCode = String(code)
            } else {
                carrierCode = nil
            }
            
            logoURL = carrier.logo
        } else {
            carrierName = route.hasTransfers ? "Несколько перевозчиков" : "Неизвестный перевозчик"
            carrierCode = nil
            logoURL = nil
        }
        
        // Используем DateFormatterHelper
        let departTime = DateFormatterHelper.formatTime(from: route.departureTime)
        let arriveTime = DateFormatterHelper.formatTime(from: route.arrivalTime)
        
        // Исправление: Форматирование длительности с проверкой
        let durationText: String
        if route.duration > 0 {
            durationText = DateFormatterHelper.formatDuration(route.duration)
        } else {
            durationText = "Время уточняется"
        }
        
        let dateText = DateFormatterHelper.formatDateFromArrivalTime(route.arrivalTime)
        
        // Логика для заметки (note) - ТОЧНО КАК НА СКРИНЕ
        let note: String?
        if route.hasTransfers {
            if let cityName = route.transferPointName, !cityName.isEmpty {
                // Убираем "вокзал" или "станция" из названия
                let cleanedName = cityName
                    .replacingOccurrences(of: " вокзал", with: "")
                    .replacingOccurrences(of: " станция", with: "")
                    .replacingOccurrences(of: " ст.", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                note = "С пересадкой в \(cleanedName)"
            } else if route.transfersCount == 1 {
                note = "С пересадкой"
            } else if route.transfersCount > 1 {
                note = "С \(route.transfersCount) пересадками"
            } else {
                note = "С пересадками"
            }
        } else {
            note = nil
        }
        
        let transportType = route.transportTypes.first ?? "train"
        
        return CarrierRowViewModel(
            carrierName: carrierName,
            logoURL: logoURL,
            transportType: transportType,
            carrierCode: carrierCode,
            dateText: dateText,
            departTime: departTime,
            arriveTime: arriveTime,
            durationText: durationText,
            note: note
        )
    }
    
    private func updateDisplayedCarriers() {
        allCarriers = filteredCarriers
        updateEmptyState()
    }
    
    private func filterByTime(_ timeString: String) -> Bool {
        guard !currentFilter.selectedDayParts.isEmpty else {
            return true
        }
        
        guard let date = DateFormatterHelper.parseDate(from: timeString) else {
            return true
        }
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        for dayPart in currentFilter.selectedDayParts {
            let range = dayPart.timeRange
            
            if range.start < range.end {
                if hour >= range.start && hour < range.end {
                    return true
                }
            } else {
                if hour >= range.start || hour < range.end {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func filterByTransportType(_ transportTypes: [String]) -> Bool {
        guard !currentFilter.selectedTransportTypes.isEmpty else { return true }
        
        for routeType in transportTypes {
            for filterType in currentFilter.selectedTransportTypes {
                if filterType.rawValue == routeType {
                    return true
                }
            }
        }
        return false
    }
    
    private func updateEmptyState() {
        showEmptyState = carriers.isEmpty
    }
    
    private func handleNetworkError(_ error: URLError) {
        switch error.code {
        case .badServerResponse:
            errorMessage = "Маршруты не найдены"
        case .timedOut:
            errorMessage = "Таймаут соединения"
        case .notConnectedToInternet:
            errorMessage = "Нет соединения с интернетом"
        default:
            errorMessage = "Ошибка сети: \(error.localizedDescription)"
        }
        showEmptyState = true
    }
    
    private func saveToCache(_ routes: [Route]) {
        guard !routes.isEmpty else { return }
        
        Self.routeCache[cacheKey] = routes
        Self.cacheTimestamp[cacheKey] = Date()
    }
    
    private func isCacheExpired() -> Bool {
        guard let timestamp = Self.cacheTimestamp[cacheKey] else {
            return true
        }
        
        return Date().timeIntervalSince(timestamp) > cacheTTL
    }
    
    static func clearCache() {
        routeCache.removeAll()
        cacheTimestamp.removeAll()
    }
}

// MARK: - Модель маршрута (упрощаем - делаем вложенной)

extension CarrierListViewModel {
    struct Route {
        let id: String
        let title: String
        let departureTime: String
        let arrivalTime: String
        let duration: Int
        let carriers: [Components.Schemas.Carrier]
        let transportTypes: [String]
        let hasTransfers: Bool
        let transfersCount: Int
        let transfers: [Components.Schemas.TransferPoint]
        let details: [Components.Schemas.JourneySegment]
        let transferPointName: String?
        
        var carrier: Components.Schemas.Carrier? {
            carriers.first
        }
    }
}
