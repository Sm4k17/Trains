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
}

enum TransfersOption: String, Identifiable, Hashable {
    case yes, no
    
    var id: Self { self }
    
    var title: String {
        self == .yes ? "Да" : "Нет"
    }
}

// MARK: - ViewModel

@MainActor
@Observable
final class ScheduleFilterViewModel {
    // MARK: - Properties
    var selectedParts: Set<DayPart> = []
    var transfers: TransfersOption? = nil
    
    // MARK: - Computed Properties
    var isApplyEnabled: Bool {
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
        transfers = nil
    }
    
    func selectAllDayParts() {
        selectedParts = Set(DayPart.allCases)
    }
    
    func hasSelectedDayPart(_ part: DayPart) -> Bool {
        selectedParts.contains(part)
    }
}
