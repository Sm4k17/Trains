// ScheduleFilterViewModel.swift
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

enum TransportType: String, CaseIterable, Identifiable, Hashable {
    case train = "train"
    case plane = "plane"
    case suburban = "suburban"
    case bus = "bus"
    case water = "water"
    case helicopter = "helicopter"
    
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .train: return "Поезда"
        case .plane: return "Самолеты"
        case .suburban: return "Электрички"
        case .bus: return "Автобусы"
        case .water: return "Водный транспорт"
        case .helicopter: return "Вертолеты"
        }
    }
    
    var iconName: String {
        switch self {
        case .train: return "train.side.front.car"
        case .plane: return "airplane"
        case .suburban: return "tram"
        case .bus: return "bus"
        case .water: return "ferry"
        case .helicopter: return "helicopter"
        }
    }
}

// MARK: - Filter Model
struct ScheduleFilter: Hashable {
    var selectedDayParts: Set<DayPart> = []
    var showTransfers: Bool?
    var selectedTransportTypes: Set<TransportType> = []
    
    var isActive: Bool {
        // Фильтр активен только если выбраны ОБА параметра: время И пересадки
        (!selectedDayParts.isEmpty && showTransfers != nil) || !selectedTransportTypes.isEmpty
    }
    
    // Проверка валидности для применения
    var isValidForApply: Bool {
        // Можно применить если выбраны оба: время и пересадки
        (!selectedDayParts.isEmpty && showTransfers != nil) || !selectedTransportTypes.isEmpty
    }
    
    static let `default` = ScheduleFilter(showTransfers: nil)
}

// MARK: - ViewModel

@MainActor
@Observable
final class ScheduleFilterViewModel {
    // MARK: - Properties
    var selectedParts: Set<DayPart> = []
    var transfers: TransfersOption? = nil
    var selectedTransportTypes: Set<TransportType> = []
    
    // Статическое хранилище для сохранения состояния фильтра
    static var savedFilter: ScheduleFilter = .default
    
    // MARK: - Computed Properties
    var isApplyEnabled: Bool {
        // Кнопка активна только если выбраны ОБА: время и пересадки ИЛИ тип транспорта
        (!selectedParts.isEmpty && transfers != nil) || !selectedTransportTypes.isEmpty
    }
    
    var selectedPartsCount: Int {
        selectedParts.count
    }
    
    var selectedTransportTypesCount: Int {
        selectedTransportTypes.count
    }
    
    var transfersText: String {
        transfers?.title ?? "Не выбрано"
    }
    
    // MARK: - Methods
    func toggleDayPart(_ part: DayPart) {
        print("🕐 Изменение времени: \(part.rawValue)")
        if selectedParts.contains(part) {
            selectedParts.remove(part)
            print("   ❌ Удалено")
        } else {
            selectedParts.insert(part)
            print("   ✅ Добавлено")
        }
        print("   Выбрано частей дня: \(selectedPartsCount)")
        print("   Можно применить фильтр: \(isApplyEnabled)")
    }
    
    func toggleTransportType(_ type: TransportType) {
        print("🚌 Изменение типа транспорта: \(type.displayName)")
        if selectedTransportTypes.contains(type) {
            selectedTransportTypes.remove(type)
            print("   ❌ Удалено")
        } else {
            selectedTransportTypes.insert(type)
            print("   ✅ Добавлено")
        }
        print("   Выбрано типов транспорта: \(selectedTransportTypesCount)")
        print("   Можно применить фильтр: \(isApplyEnabled)")
    }
    
    func selectTransfers(_ option: TransfersOption) {
        print("🔄 Выбор пересадок: \(option.title)")
        transfers = option
        print("   Можно применить фильтр: \(isApplyEnabled)")
    }
    
    func clearAll() {
        print("🗑️ Очистка всех фильтров")
        selectedParts.removeAll()
        transfers = nil
        selectedTransportTypes.removeAll()
        print("   Можно применить фильтр: \(isApplyEnabled)")
    }
    
    func selectAllDayParts() {
        print("🕐 Выбор всех частей дня")
        selectedParts = Set(DayPart.allCases)
        print("   Можно применить фильтр: \(isApplyEnabled)")
    }
    
    func selectAllTransportTypes() {
        print("🚌 Выбор всех типов транспорта")
        selectedTransportTypes = Set(TransportType.allCases)
        print("   Можно применить фильтр: \(isApplyEnabled)")
    }
    
    func deselectAllTransportTypes() {
        print("🚌 Снятие всех типов транспорта")
        selectedTransportTypes.removeAll()
        print("   Можно применить фильтр: \(isApplyEnabled)")
    }
    
    func hasSelectedDayPart(_ part: DayPart) -> Bool {
        selectedParts.contains(part)
    }
    
    func hasSelectedTransportType(_ type: TransportType) -> Bool {
        selectedTransportTypes.contains(type)
    }
    
    func applyFilter() {
        print("✅ Применение фильтра:")
        print("   - Выбрано частей дня: \(selectedPartsCount)")
        print("   - Пересадки: \(transfers?.title ?? "не выбрано")")
        print("   - Типы транспорта: \(selectedTransportTypesCount)")
        print("   - Фильтр активен: \(isApplyEnabled)")
        
        // Сохраняем фильтр в статической переменной
        ScheduleFilterViewModel.savedFilter = ScheduleFilter(
            selectedDayParts: selectedParts,
            showTransfers: transfers?.boolValue,
            selectedTransportTypes: selectedTransportTypes
        )
        
        print("💾 Фильтр сохранен")
    }
    
    func loadSavedFilter() {
        print("📂 Загрузка сохраненного фильтра")
        let savedFilter = ScheduleFilterViewModel.savedFilter
        self.selectedParts = savedFilter.selectedDayParts
        self.selectedTransportTypes = savedFilter.selectedTransportTypes
        
        // Если showTransfers = nil, то transfers = nil (ничего не выбрано)
        if let showTransfers = savedFilter.showTransfers {
            self.transfers = showTransfers ? .yes : .no
        } else {
            self.transfers = nil
        }
        
        print("   - Загружено частей дня: \(selectedPartsCount)")
        print("   - Пересадки: \(transfers?.title ?? "не выбрано")")
        print("   - Типы транспорта: \(selectedTransportTypesCount)")
    }
}
