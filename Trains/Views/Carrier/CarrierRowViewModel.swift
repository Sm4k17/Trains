//
//  CarrierRowViewModel.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

// MARK: - ViewModel
struct CarrierRowViewModel: Identifiable {
    let id = UUID()
    let carrierName: String
    let logoSystemName: String?
    let dateText: String
    let departTime: String
    let arriveTime: String
    let durationText: String
    let note: String?
}

extension CarrierRowViewModel {
    static let mock: [CarrierRowViewModel] = [
        .init(carrierName: "РЖД", logoSystemName: "train.side.front.car",
              dateText: "14 января", departTime: "22:30", arriveTime: "08:15",
              durationText: "20 часов", note: "С пересадкой в Костроме"),
        .init(carrierName: "ФГК", logoSystemName: "train.side.front.car",
              dateText: "15 января", departTime: "01:15", arriveTime: "09:00",
              durationText: "9 часов", note: nil),
        .init(carrierName: "Урал логистика", logoSystemName: "train.side.front.car",
              dateText: "15 января", departTime: "12:30", arriveTime: "21:00",
              durationText: "9 часов", note: nil),
        .init(carrierName: "РЖД", logoSystemName: "train.side.front.car",
              dateText: "17 января", departTime: "22:30", arriveTime: "08:15",
              durationText: "20 часов", note: "С пересадкой в Костроме"),
        .init(carrierName: "РЖД", logoSystemName: "train.side.front.car",
              dateText: "17 января", departTime: "22:30", arriveTime: "08:15",
              durationText: "20 часов", note: "С пересадкой в Костроме"),
        .init(carrierName: "Урал логистика", logoSystemName: "train.side.front.car",
              dateText: "17 января", departTime: "12:30", arriveTime: "21:00",
              durationText: "9 часов", note: nil)
    ]
}
