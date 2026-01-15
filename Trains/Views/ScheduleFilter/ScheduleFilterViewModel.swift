//
//  ScheduleFilterViewModel.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 12.01.2026.
//

import SwiftUI

// MARK: - Enums
enum DayPart: String, CaseIterable, Identifiable, Hashable {
    case morning = "Утро 06:00 – 12:00"
    case day     = "День 12:00 – 18:00"
    case evening = "Вечер 18:00 – 00:00"
    case night   = "Ночь 00:00 – 06:00"
    
    var id: Self { self }
    
    var timeRange: (start: Int, end: Int) {
        switch self {
        case .morning: return (6, 12)
        case .day:     return (12, 18)
        case .evening: return (18, 24)
        case .night:   return (0, 6)
        }
    }
}

enum TransfersOption: String, Identifiable, Hashable {
    case yes, no
    
    var id: Self { self }
    
    var title: String {
        self == .yes ? "Да" : "Нет"
    }
    
    var boolValue: Bool {
        self == .yes
    }
}

// MARK: - Filter Model
struct ScheduleFilter: Hashable {
    var selectedDayParts: Set<DayPart> = []
    var showTransfers: Bool?
    
    var isActive: Bool {
        !selectedDayParts.isEmpty
    }
    
    // showTransfers = nil означает, что ничего не выбрано
    static let `default` = ScheduleFilter(showTransfers: nil)
}

// MARK: - ViewModel

@MainActor
@Observable
final class ScheduleFilterViewModel {
    // MARK: - Properties
    var selectedParts: Set<DayPart> = []
    var transfers: TransfersOption? = nil
    
    // Статическое хранилище для сохранения состояния фильтра
    static var savedFilter: ScheduleFilter = .default
    
    // MARK: - Computed Properties
    var isApplyEnabled: Bool {
        // Кнопка активна когда есть выбор в обоих блоках
        !selectedParts.isEmpty && transfers != nil
    }
    
    var selectedPartsCount: Int {
        selectedParts.count
    }
    
    var transfersText: String {
        transfers?.title ?? "Не выбрано"
    }
    
    // MARK: - Methods
    func toggleDayPart(_ part: DayPart) {
        if selectedParts.contains(part) {
            selectedParts.remove(part)
        } else {
            selectedParts.insert(part)
        }
    }
    
    func selectTransfers(_ option: TransfersOption) {
        transfers = option
    }
    
    func clearAll() {
        selectedParts.removeAll()
        transfers = nil // Сбрасываем выбор пересадок
    }
    
    func selectAllDayParts() {
        selectedParts = Set(DayPart.allCases)
    }
    
    func hasSelectedDayPart(_ part: DayPart) -> Bool {
        selectedParts.contains(part)
    }
    
    func applyFilter() {
        // Сохраняем фильтр в статической переменной
        ScheduleFilterViewModel.savedFilter = ScheduleFilter(
            selectedDayParts: selectedParts,
            showTransfers: transfers?.boolValue
        )
    }
    
    func loadSavedFilter() {
        let savedFilter = ScheduleFilterViewModel.savedFilter
        self.selectedParts = savedFilter.selectedDayParts
        
        // Если showTransfers = nil, то transfers = nil (ничего не выбрано)
        if let showTransfers = savedFilter.showTransfers {
            self.transfers = showTransfers ? .yes : .no
        } else {
            self.transfers = nil
        }
    }
}
