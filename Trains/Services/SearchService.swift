//
//  SearchService.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 20.11.2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

protocol SearchServiceProtocol: Sendable {
    func search(
        from: String,
        to: String,
        date: String?,
        transportTypes: String?,
        limit: Int?
    ) async throws -> Components.Schemas.SearchResponse
}

final class SearchService: SearchServiceProtocol, @unchecked Sendable {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func search(
        from: String,
        to: String,
        date: String? = nil,
        transportTypes: String? = nil,
        limit: Int? = 100
    ) async throws -> Components.Schemas.SearchResponse {
        let response = try await client.getSearch(query: .init(
            apikey: apikey,
            from: from,
            to: to,
            format: "json",
            lang: "ru_RU",
            date: date,
            transport_types: transportTypes,
            limit: limit
        ))
        return try response.ok.body.json
    }
}
