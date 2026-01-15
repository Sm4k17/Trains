//
//  NearestStationsService.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 19.11.2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

protocol NearestStationsServiceProtocol: Sendable {
    func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> Components.Schemas.Stations
}

final class NearestStationsService: NearestStationsServiceProtocol, @unchecked Sendable {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getNearestStations(lat: Double, lng: Double, distance: Int = 50) async throws -> Components.Schemas.Stations {
        let response = try await client.getNearestStations(query: .init(
            apikey: apikey,
            lat: lat,
            lng: lng,
            distance: distance,
            format: "json",
            lang: "ru_RU"
        ))
        return try response.ok.body.json
    }
}
