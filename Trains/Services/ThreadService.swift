//
//  ThreadService.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 20.11.2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

protocol ThreadServiceProtocol: Sendable {
    func getThread(
        uid: String,
        from: String?,
        to: String?,
        date: String?
    ) async throws -> Components.Schemas.ThreadResponse
}

final class ThreadService: ThreadServiceProtocol, @unchecked Sendable {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getThread(
        uid: String,
        from: String? = nil,
        to: String? = nil,
        date: String? = nil
    ) async throws -> Components.Schemas.ThreadResponse {
        let response = try await client.getThread(query: .init(
            apikey: apikey,
            uid: uid,
            from: from,
            to: to,
            format: "json",
            lang: "ru_RU",
            date: date
        ))
        return try response.ok.body.json
    }
}
