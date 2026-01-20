//
//  AppRoute.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 06.01.2026.
//

enum AppRoute: Hashable {
    // Routes Tab
    case carrierList(from: String, to: String)
    case carrierInfo(carrierCode: String, logoAssetName: String?)
    case scheduleFilter
    case citySearch(context: CitySearchContext, city: String = "", station: String = "")
    case stationSearch(context: CitySearchContext, city: String, station: String = "")
    
    // Settings Tab
    case userAgreement
    
    enum CitySearchContext: String, Hashable, CaseIterable {
        case from
        case to
        
        var title: String {
            switch self {
            case .from: return "Откуда"
            case .to: return "Куда"
            }
        }
    }
}
