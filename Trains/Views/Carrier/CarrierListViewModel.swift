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
    
    // MARK: - Constants
    
    private enum Constants {
        static let cacheTTL: TimeInterval = 300
        static let searchLimit = 50
        static let defaultTransportType = "train"
        static let defaultTimeFormat = "--:--"
        static let unknownCarrierName = "Неизвестный перевозчик"
        static let multipleCarriersName = "Несколько перевозчиков"
        static let durationUnavailable = "Время уточняется"
        static let withTransfer = "С пересадкой"
    }
    
    // MARK: - Properties
    
    private var allSegments: [Components.Schemas.Segment] = [] {
        didSet {
            updateFilteredCarriers()
            updateDisplayedCarriers()
        }
    }
    
    private var allCarriers: [CarrierRowViewModel] = []
    private var _filteredCarriers: [CarrierRowViewModel] = []
    
    var carriers: [CarrierRowViewModel] {
        hasActiveFilter ? _filteredCarriers : allCarriers
    }
    
    var isLoading = false
    var showEmptyState = false
    var errorMessage: String?
    
    private var currentFilter: ScheduleFilter = .default {
        didSet {
            if oldValue != currentFilter {
                updateFilteredCarriers()
                updateDisplayedCarriers()
            }
        }
    }
    
    private let networkClient: NetworkClient
    private let fromText: String
    private let toText: String
    
    // MARK: - Caching
    
    private static var segmentsCache: [String: [Components.Schemas.Segment]] = [:]
    private static var cacheTimestamp: [String: Date] = [:]
    
    private var cacheKey: String {
        "\(fromText)|\(toText)"
    }
    
    // MARK: - Computed Properties
    
    var headerTitle: String {
        "\(fromText) → \(toText)"
    }
    
    var hasActiveFilter: Bool {
        currentFilter.isActive
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
        if !forceRefresh, let cachedSegments = Self.segmentsCache[cacheKey], !isCacheExpired() {
            self.allSegments = cachedSegments
            self.isLoading = false
            updateEmptyState()
            return
        }
        
        await loadFromNetwork()
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
        let snapshot = carriers
        guard index >= 0 && index < snapshot.count else { return nil }
        
        let carrier = snapshot[index]
        
        guard let code = carrier.carrierCode,
              let intCode = Int(code),
              intCode > 0 else {
            return nil
        }
        
        return (code, carrier.logoAssetName)
    }
    
    // MARK: - Private Methods
    
    private func loadFromNetwork() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let searchData = networkClient.getSearchData(from: fromText, to: toText)
            async let cachedCities = networkClient.getAllCities(cached: true)
            
            let (fromToCodes, _) = try await (searchData, cachedCities)
            
            let response = try await networkClient.search(
                from: fromToCodes.fromCode,
                to: fromToCodes.toCode,
                limit: Constants.searchLimit
            )
            
            await processSearchResponse(response)
            
        } catch {
            handleNetworkError(error)
        }
        
        isLoading = false
        updateEmptyState()
    }
    
    private func processSearchResponse(_ response: Components.Schemas.SearchResponse) async {
        guard let segments = response.segments else {
            allSegments = []
            showEmptyState = true
            return
        }
        
        #if DEBUG
        debugPrintSegments(segments)
        #endif
        
        allSegments = segments
    }
    
    private func convertToCarrierRowViewModel(_ segment: Components.Schemas.Segment) -> CarrierRowViewModel {
        _ = segment.has_transfers ?? false
        
        // Извлечение информации о перевозчике
        let carrierInfo = extractCarrierInfo(from: segment)
        
        // Форматирование времени
        let departTime = formatTime(segment.departure)
        let arriveTime = formatTime(segment.arrival)
        
        // Расчет длительности
        let durationText = calculateDuration(for: segment)
        
        // Дата
        let dateText = formatDate(from: segment.arrival ?? segment.departure)
        
        // Примечание
        let note = createNoteForSegment(segment)
        
        // Тип транспорта
        let transportType = extractTransportType(from: segment)
        
        return CarrierRowViewModel(
            carrierName: carrierInfo.name,
            logoURL: carrierInfo.logo,
            transportType: transportType,
            carrierCode: carrierInfo.code > 0 ? String(carrierInfo.code) : nil,
            dateText: dateText,
            departTime: departTime,
            arriveTime: arriveTime,
            durationText: durationText,
            note: note
        )
    }
    
    private func extractCarrierInfo(from segment: Components.Schemas.Segment) -> (name: String, code: Int, logo: String?) {
        guard let carrier = findCarrier(in: segment) else {
            return (name: Constants.unknownCarrierName, code: 0, logo: nil)
        }
        
        let name = segment.has_transfers == false
            ? (carrier.title ?? Constants.unknownCarrierName)
            : (carrier.title ?? Constants.multipleCarriersName)
        
        return (
            name: name,
            code: carrier.code ?? 0,
            logo: carrier.logo
        )
    }
    
    private func findCarrier(in segment: Components.Schemas.Segment) -> Components.Schemas.Carrier? {
        if segment.has_transfers == false {
            return segment.thread?.carrier
        }
        
        // Поиск в details для маршрутов с пересадками
        for detail in segment.details ?? [] {
            if case .JourneySegment(let journey) = detail {
                return journey.thread?.carrier
            }
        }
        
        return nil
    }
    
    private func extractTransportType(from segment: Components.Schemas.Segment) -> String {
        if segment.has_transfers == false {
            return segment.thread?.transport_type ?? Constants.defaultTransportType
        }
        
        return segment.transport_types?.first ?? Constants.defaultTransportType
    }
    
    private func calculateDuration(for segment: Components.Schemas.Segment) -> String {
        let hasTransfers = segment.has_transfers ?? false
        
        if hasTransfers {
            return calculateTotalDurationForTransferSegment(segment)
        } else if let duration = segment.duration, duration > 0 {
            return DateFormatterHelper.formatDuration(Int(duration))
        } else {
            return Constants.durationUnavailable
        }
    }
    
    private func calculateTotalDurationForTransferSegment(_ segment: Components.Schemas.Segment) -> String {
        guard let details = segment.details else {
            return Constants.durationUnavailable
        }
        
        var totalSeconds = 0
        
        for detail in details {
            switch detail {
            case .JourneySegment(let journey):
                if let duration = journey.duration {
                    totalSeconds += Int(duration)
                }
            case .TransferStop(let transferStop):
                if let transferDuration = transferStop.duration {
                    totalSeconds += Int(transferDuration)
                }
            }
        }
        
        if let segmentDuration = segment.duration, segmentDuration > 0 {
            totalSeconds = max(totalSeconds, Int(segmentDuration))
        }
        
        guard totalSeconds > 0 else {
            return Constants.durationUnavailable
        }
        
        return DateFormatterHelper.formatDuration(totalSeconds)
    }
    
    private func formatTime(_ timeString: String?) -> String {
        guard let timeString = timeString else {
            return Constants.defaultTimeFormat
        }
        return DateFormatterHelper.formatTime(from: timeString)
    }
    
    private func formatDate(from timeString: String?) -> String {
        guard let timeString = timeString else {
            return ""
        }
        return DateFormatterHelper.formatDateFromArrivalTime(timeString)
    }
    
    private func createNoteForSegment(_ segment: Components.Schemas.Segment) -> String? {
        guard segment.has_transfers == true else { return nil }
        
        guard let transferCity = extractTransferCity(from: segment) else {
            return Constants.withTransfer
        }
        
        let cleanedCity = transferCity
            .replacingOccurrences(of: " вокзал", with: "")
            .replacingOccurrences(of: " станция", with: "")
            .replacingOccurrences(of: " ст.", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return "С пересадкой в \(cleanedCity)"
    }
    
    private func extractTransferCity(from segment: Components.Schemas.Segment) -> String? {
        guard segment.has_transfers == true else { return nil }
        
        // Поле transfers (приоритет)
        if let transfers = segment.transfers, !transfers.isEmpty {
            let firstTransfer = transfers[0]
            
            switch firstTransfer {
            case .Location(let location):
                return location.popular_title ?? location.title ?? location.short_title
            case .Station(let station):
                return station.popular_title ?? station.title ?? station.short_title
            }
        }
        
        // Резервный вариант: TransferStop
        if let details = segment.details {
            for detail in details {
                switch detail {
                case .TransferStop(let transferStop):
                    if let transferPoint = transferStop.transfer_point {
                        return transferPoint.popular_title ?? transferPoint.title ?? transferPoint.short_title
                    }
                case .JourneySegment:
                    continue
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Filtering
    
    private func updateFilteredCarriers() {
        var segmentsToProcess = allSegments
        
        // Фильтр пересадок
        if let showTransfers = currentFilter.showTransfers {
            segmentsToProcess = segmentsToProcess.filter { segment in
                showTransfers ? segment.has_transfers == true : segment.has_transfers == false
            }
        }
        
        // Фильтр по времени
        if !currentFilter.selectedDayParts.isEmpty {
            segmentsToProcess = segmentsToProcess.filter { segment in
                filterByTime(segment.departure)
            }
        }
        
        // Фильтр по типу транспорта
        if !currentFilter.selectedTransportTypes.isEmpty {
            segmentsToProcess = segmentsToProcess.filter { segment in
                filterByTransportType(segment)
            }
        }
        
        _filteredCarriers = segmentsToProcess.map { convertToCarrierRowViewModel($0) }
    }
    
    private func updateDisplayedCarriers() {
        allCarriers = _filteredCarriers
        updateEmptyState()
    }
    
    private func filterByTime(_ timeString: String?) -> Bool {
        guard let timeString = timeString,
              !currentFilter.selectedDayParts.isEmpty else {
            return true
        }
        
        guard let date = DateFormatterHelper.parseDate(from: timeString) else {
            return true
        }
        
        let hour = Calendar.current.component(.hour, from: date)
        
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
    
    private func filterByTransportType(_ segment: Components.Schemas.Segment) -> Bool {
        guard !currentFilter.selectedTransportTypes.isEmpty else { return true }
        
        let transportTypes = segment.has_transfers == false
            ? [segment.thread?.transport_type].compactMap { $0 }
            : segment.transport_types ?? []
        
        return transportTypes.contains { transportType in
            currentFilter.selectedTransportTypes.contains { $0.rawValue == transportType }
        }
    }
    
    private func updateEmptyState() {
        showEmptyState = carriers.isEmpty
    }
    
    // MARK: - Error Handling
    
    private func handleNetworkError(_ error: Error) {
        switch error {
        case let urlError as URLError:
            switch urlError.code {
            case .badServerResponse:
                errorMessage = "Маршруты не найдены"
            case .timedOut:
                errorMessage = "Таймаут соединения"
            case .notConnectedToInternet:
                errorMessage = "Нет соединения с интернетом"
            default:
                errorMessage = "Ошибка сети: \(urlError.localizedDescription)"
            }
        case _ as DecodingError:
            errorMessage = "Ошибка обработки данных"
        default:
            errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
        }
        showEmptyState = true
    }
    
    // MARK: - Cache Management
    
    private func saveToCache(_ segments: [Components.Schemas.Segment]) {
        guard !segments.isEmpty else { return }
        
        Self.segmentsCache[cacheKey] = segments
        Self.cacheTimestamp[cacheKey] = Date()
    }
    
    private func isCacheExpired() -> Bool {
        guard let timestamp = Self.cacheTimestamp[cacheKey] else {
            return true
        }
        
        return Date().timeIntervalSince(timestamp) > Constants.cacheTTL
    }
    
    static func clearCache() {
        segmentsCache.removeAll()
        cacheTimestamp.removeAll()
    }
    
    // MARK: - Debug Helpers
    
    #if DEBUG
    private func debugPrintSegments(_ segments: [Components.Schemas.Segment]) {
        print("=== DEBUG: Получено сегментов от API: \(segments.count)")
        for (index, segment) in segments.enumerated() {
            print("Сегмент \(index):")
            print("  - has_transfers: \(segment.has_transfers ?? false)")
            print("  - transfers count: \(segment.transfers?.count ?? 0)")
            
            if let transfers = segment.transfers, !transfers.isEmpty {
                let firstTransfer = transfers[0]
                
                switch firstTransfer {
                case .Location(let location):
                    print("  - Город пересадки (Location): \(location.popular_title ?? location.title ?? location.short_title ?? "no title")")
                case .Station(let station):
                    print("  - Станция пересадки (Station): \(station.popular_title ?? station.title ?? station.short_title ?? "no title")")
                }
            }
        }
    }
    #endif
}
