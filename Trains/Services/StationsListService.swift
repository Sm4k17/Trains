//
//  StationsListService.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 20.11.2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

protocol StationsListServiceProtocol {
    func getStationsList() async throws -> String
}

final class StationsListService: StationsListServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getStationsList() async throws -> String {
        let response = try await client.getStationsList(query: .init(
            apikey: apikey,
            format: "json"
        ))
        
        // Простой подход - используем description для получения строки
        let body = try response.ok.body
        return String(describing: body)
    }
}
