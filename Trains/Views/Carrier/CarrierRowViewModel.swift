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
    var logoURL: String?
    var logoSystemName: String?
    var carrierCode: String?
    var dateText: String
    var departTime: String
    var arriveTime: String
    var durationText: String
    var note: String?
    var transportType: String?
    
    var logoAssetName: String? {
        logoSystemName
    }
    
    init(
        carrierName: String,
        logoURL: String? = nil,
        transportType: String? = nil,
        carrierCode: String? = nil,
        dateText: String,
        departTime: String,
        arriveTime: String,
        durationText: String,
        note: String? = nil
    ) {
        self.carrierName = carrierName
        self.logoURL = logoURL
        self.transportType = transportType
        self.carrierCode = carrierCode
        self.dateText = dateText
        self.departTime = departTime
        self.arriveTime = arriveTime
        self.durationText = durationText
        self.note = note
        
        self.logoSystemName = determineFallbackIconName()
    }
    
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
        self.transportType = nil
        self.logoURL = nil
    }
    
    private func determineFallbackIconName() -> String {
        switch transportType {
        case "plane":
            return "airplane"
        case "train":
            return "train.side.front.car"
        case "bus":
            return "bus"
        case "suburban":
            return "tram"
        default:
            let lowercasedName = carrierName.lowercased()
            
            if lowercasedName.contains("авиа") ||
               lowercasedName.contains("airlines") ||
               lowercasedName.contains("аэро") {
                return "airplane"
            } else if lowercasedName.contains("жд") ||
                      lowercasedName.contains("поезд") ||
                      lowercasedName.contains("ржд") {
                return "train.side.front.car"
            } else if lowercasedName.contains("авто") ||
                      lowercasedName.contains("автобус") {
                return "bus"
            } else {
                return "train.side.front.car"
            }
        }
    }
}
