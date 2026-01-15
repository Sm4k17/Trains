//
//  CarrierService.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 20.11.2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias CarrierResponse = Components.Schemas.CarrierResponse

protocol CarrierServiceProtocol {
    func getCarrier(code: String) async throws -> CarrierResponse
}

final class CarrierService: CarrierServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getCarrier(code: String) async throws -> CarrierResponse {
        // Определяем system
        let system: Operations.getCarrier.Input.Query.systemPayload?
        
        if code.rangeOfCharacter(from: .letters) != nil {
            system = .iata
        } else {
            system = nil
        }
        
        let response = try await client.getCarrier(query: .init(
            apikey: apikey,
            code: code,
            format: "json",
            lang: "ru_RU",
            system: system
        ))
        return try response.ok.body.json
    }
}
