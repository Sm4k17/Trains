//
//  SearchService.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 20.11.2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias SearchResponse = Components.Schemas.SearchResponse

protocol SearchServiceProtocol {
    func search(from: String, to: String, date: String?) async throws -> SearchResponse
}

final class SearchService: SearchServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func search(from: String, to: String, date: String? = nil) async throws -> SearchResponse {
        let response = try await client.getSearch(query: .init(
            apikey: apikey,
            from: from,
            to: to,
            format: "json",
            date: date
        ))
        return try response.ok.body.json
    }
}
