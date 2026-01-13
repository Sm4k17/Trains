//
//  CarrierRowViewModel.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 12.01.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class CarrierRowViewModel: Identifiable {
    let id = UUID()
    var carrierName: String
    var logoSystemName: String?
    var carrierCode: String?
    var dateText: String
    var departTime: String
    var arriveTime: String
    var durationText: String
    var note: String?
    
    init(
        carrierName: String,
        logoSystemName: String? = nil,
        carrierCode: String? = nil,
        dateText: String,
        departTime: String,
        arriveTime: String,
        durationText: String,
        note: String? = nil
    ) {
        self.carrierName = carrierName
        self.logoSystemName = logoSystemName
        self.carrierCode = carrierCode
        self.dateText = dateText
        self.departTime = departTime
        self.arriveTime = arriveTime
        self.durationText = durationText
        self.note = note
    }
}
