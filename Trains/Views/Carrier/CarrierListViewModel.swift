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
    
    // MARK: - Computed Properties
    
    var headerTitle: String {
        "\(fromText) → \(toText)"
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
                
                return timeFilterPassed && transferFilterPassed
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
        networkClient: NetworkClient
    ) {
        self.fromText = fromText
        self.toText = toText
        self.networkClient = networkClient
    }
    
    // MARK: - Public Methods
    
    func loadCarriers() async {
        isLoading = true
        errorMessage = nil
        carriers = []
        
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
                limit: 20
            )
            
            await processSearchResponse(response)
            
        } catch let error as URLError where error.code == .badServerResponse {
            errorMessage = "Маршруты не найдены между выбранными пунктами"
            showEmptyState = true
        } catch {
            errorMessage = "Ошибка загрузки данных"
            showEmptyState = true
        }
        
        isLoading = false
        updateEmptyState()
    }
    
    func applySavedFilter() {
        // Загружаем сохраненный фильтр
        self.currentFilter = ScheduleFilterViewModel.savedFilter
        updateEmptyState()
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
    
    // MARK: - Private Methods
    
    private func processSearchResponse(_ response: Components.Schemas.SearchResponse) async {
        guard let segments = response.segments else {
            carriers = []
            showEmptyState = true
            return
        }
        
        var carrierViewModels: [CarrierRowViewModel] = []
        
        for segment in segments {
            guard let thread = segment.thread,
                  let departure = segment.departure,
                  let arrival = segment.arrival else {
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
            let transportType = thread.transport_type
            
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
    
    private func updateEmptyState() {
        showEmptyState = displayCarriers.isEmpty
    }
    
    private func formatTime(from timeString: String) -> String {
        let components = timeString.split(separator: ":")
        
        guard components.count >= 2 else {
            return "--:--"
        }
        
        let hour = String(components[0])
        let minute = String(components[1])
        
        return "\(hour):\(minute)"
    }
    
    private func formatDate(from timeString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        guard let date = dateFormatter.date(from: timeString) else {
            return formatCurrentDate()
        }
        
        dateFormatter.dateFormat = "d MMMM"
        return dateFormatter.string(from: date)
    }
    
    private func formatCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM"
        return dateFormatter.string(from: Date())
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
}
