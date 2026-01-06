//
//  CarrierRowViewModel.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

// MARK: - ViewModel

struct CarrierRowViewModel: Identifiable {
    
    // MARK: - Properties
    
    let id = UUID()
    let carrierName: String
    let logoSystemName: String?
    let carrierCode: String?
    let dateText: String
    let departTime: String
    let arriveTime: String
    let durationText: String
    let note: String?
}

// MARK: - Mock Data

extension CarrierRowViewModel {
    
    // MARK: - Mock Instances
    
    static let mock: [CarrierRowViewModel] = [
        .init(
            carrierName: "РЖД",
            logoSystemName: "train.side.front.car",
            carrierCode: "680",
            dateText: "14 января",
            departTime: "22:30",
            arriveTime: "08:15",
            durationText: "20 часов",
            note: "С пересадкой в Костроме"
        ),
        .init(
            carrierName: "ФГК",
            logoSystemName: "box.truck.fill",
            carrierCode: "104",
            dateText: "15 января",
            departTime: "01:15",
            arriveTime: "09:00",
            durationText: "9 часов",
            note: nil
        ),
        .init(
            carrierName: "S7 Airlines",
            logoSystemName: "airplane",
            carrierCode: "S7",
            dateText: "15 января",
            departTime: "12:30",
            arriveTime: "21:00",
            durationText: "9 часов",
            note: nil
        ),
        .init(
            carrierName: "Аэрофлот",
            logoSystemName: "airplane",
            carrierCode: "SU",
            dateText: "16 января",
            departTime: "08:45",
            arriveTime: "11:30",
            durationText: "2 часа 45 минут",
            note: nil
        ),
        .init(
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
}
