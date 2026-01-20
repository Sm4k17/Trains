//
//  StationsListService.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 20.11.2025.
//

import OpenAPIRuntime
import Foundation

typealias getStationsResponse = Components.Schemas.getStationsResponse

protocol StationsListServiceProtocol: Sendable {
    /// полный список станций, информацию о которых предоставляют Яндекс Расписания
    func getStations() async throws -> getStationsResponse
}

final class StationsListService: StationsListServiceProtocol, @unchecked Sendable {
    
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getStations() async throws -> getStationsResponse {
        let response = try await client.getStations(query: .init(
            apikey: apikey,
            format: nil,
            lang: nil
        ))
        
        let responseBody = try response.ok.body.html
        
        let limit = 50 * 1024 * 1024 // 50Mb

        let fullData = try await Data(collecting: responseBody, upTo: limit)
        
        let allStations = try JSONDecoder().decode(getStationsResponse.self, from: fullData)
        
        return allStations
    }
}
