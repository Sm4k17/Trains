//
//  StationService.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 15.01.2026.
//

import Foundation

protocol StationServiceProtocol: Sendable {
    func getStationsByCity(_ cityName: String, cached: Bool) async throws -> [String]
}

final class StationService: StationServiceProtocol {
    
    static let shared = StationService()
    
    private let networkService: NetworkService
    
    private init() {
        self.networkService = NetworkService.shared
    }
    
    func getStationsByCity(_ cityName: String, cached: Bool = true) async throws -> [String] {
        let networkClient = networkService.createNetworkClient()
        return try await networkClient.getStationsByCity(cityName, cached: cached)
    }
}
