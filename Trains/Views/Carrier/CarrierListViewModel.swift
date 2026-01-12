//
//  CarrierListViewModel.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 12.01.2026.
//

import Foundation
import Observation

@Observable
final class CarrierListViewModel {
    
    // MARK: - Properties
    
    var carriers: [CarrierRowViewModel] = []
    var isLoading = false
    var showEmptyState = false
    var errorMessage: String?
    
    private let carrierService: CarrierServiceProtocol
    private let fromCity: String
    private let toCity: String
    
    // MARK: - Computed Properties
    
    var headerTitle: String {
        "\(fromCity) → \(toCity)"
    }
    
    // MARK: - Mock Data
    
    private let mockData = [
        CarrierRowViewModel(
            carrierName: "РЖД",
            logoSystemName: "train.side.front.car",
            carrierCode: "680",
            dateText: "14 января",
            departTime: "22:30",
            arriveTime: "08:15",
            durationText: "20 часов",
            note: "С пересадкой в Костроме"
        ),
        CarrierRowViewModel(
            carrierName: "ФГК",
            logoSystemName: "box.truck.fill",
            carrierCode: "104",
            dateText: "15 января",
            departTime: "01:15",
            arriveTime: "09:00",
            durationText: "9 часов",
            note: nil
        ),
        CarrierRowViewModel(
            carrierName: "S7 Airlines",
            logoSystemName: "airplane",
            carrierCode: "S7",
            dateText: "15 января",
            departTime: "12:30",
            arriveTime: "21:00",
            durationText: "9 часов",
            note: nil
        ),
        CarrierRowViewModel(
            carrierName: "Аэрофлот",
            logoSystemName: "airplane",
            carrierCode: "SU",
            dateText: "16 января",
            departTime: "08:45",
            arriveTime: "11:30",
            durationText: "2 часа 45 минут",
            note: nil
        ),
        CarrierRowViewModel(
            carrierName: "ТрансКонтейнер",
            logoSystemName: "shippingbox.fill",
            carrierCode: "113",
            dateText: "17 января",
            departTime: "14:00",
            arriveTime: "06:00",
            durationText: "16 часов",
            note: "Грузовой поезд"
        )
    ]
    
    // MARK: - Initialization
    
    init(fromCity: String, toCity: String, carrierService: CarrierServiceProtocol) {
        self.fromCity = fromCity
        self.toCity = toCity
        self.carrierService = carrierService
    }
    
    // MARK: - Public Methods
    
    @MainActor
    func loadCarriers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Имитация загрузки данных
            try await Task.sleep(nanoseconds: 500_000_000)
            
            // Временно используем мок данные
            carriers = mockData
            showEmptyState = carriers.isEmpty
            
        } catch {
            errorMessage = "Ошибка загрузки данных"
            carriers = mockData
        }
        
        isLoading = false
    }
    
    func getCarrierInfo(for index: Int) -> (code: String, logoName: String)? {
        guard index >= 0 && index < carriers.count else { return nil }
        let carrier = carriers[index]
        
        guard let code = carrier.carrierCode,
              let logoName = carrier.logoSystemName else {
            return nil
        }
        
        return (code, logoName)
    }
}
