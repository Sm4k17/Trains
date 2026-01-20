//
//  CityService.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 15.01.2026.
//

import Foundation

protocol CityServiceProtocol: Sendable {
    func getAllCities(cached: Bool) async throws -> [String]
    func getCityID(cityName: String) async throws -> String?
}

final class CityService: CityServiceProtocol {
    
    static let shared = CityService()
    
    private let networkService: NetworkService
    
    private init() {
        self.networkService = NetworkService.shared
    }
    
    func getAllCities(cached: Bool = true) async throws -> [String] {
        let networkClient = NetworkService.shared.networkClient
        return try await networkClient.getAllCities(cached: cached)
    }
    
    func getCityID(cityName: String) async throws -> String? {
        let networkClient = NetworkService.shared.networkClient
        return try await networkClient.getCityID(cityName: cityName)
    }
}
