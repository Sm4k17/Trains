//
//  NetworkService.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 13.01.2026.
//

import Foundation
import OpenAPIURLSession

class NetworkService {
    
    private let apiKey = "a63c3bd4-fd50-47a4-a56b-def74416d733"
    
    func createNetworkClient() -> NetworkClient {
        let client = Client(
            serverURL: try! Servers.Server1.url(),
            transport: URLSessionTransport()
        )
        return NetworkClient(client: client, apikey: apiKey)
    }
}
