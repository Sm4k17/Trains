//
//  NearestSettlementService.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 20.11.2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

protocol NearestSettlementServiceProtocol: Sendable {
    func getNearestSettlement(lat: Double, lng: Double, distance: Int?) async throws -> Components.Schemas.NearestSettlement
}

final class NearestSettlementService: NearestSettlementServiceProtocol, @unchecked Sendable {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getNearestSettlement(lat: Double, lng: Double, distance: Int? = 50) async throws -> Components.Schemas.NearestSettlement {
        let response = try await client.getNearestSettlement(query: .init(
            apikey: apikey,
            lat: lat,
            lng: lng,
            distance: distance,
            lang: "ru_RU",
            format: "json"
        ))
        return try await response.ok.body.json
    }
}
