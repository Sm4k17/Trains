//
//  ThreadService.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 20.11.2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias ThreadResponse = Components.Schemas.ThreadResponse

protocol ThreadServiceProtocol {
    func getThread(uid: String) async throws -> ThreadResponse
}

final class ThreadService: ThreadServiceProtocol {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getThread(uid: String) async throws -> ThreadResponse {
        let response = try await client.getThread(query: .init(
            apikey: apikey,
            uid: uid,
            format: "json"  
        ))
        return try response.ok.body.json
    }
}
