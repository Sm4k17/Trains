//
//  NetworkService.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 13.01.2026.
//

import Foundation
import OpenAPIURLSession

class NetworkService {
    
    private let apiKey = "17a7b5d3-ce93-4508-bdd7-5058909c0fbd"
    
    // MARK: - Shared Instance (синглтон для кэша)
    static let shared = NetworkService()
    
    // MARK: - Shared NetworkClient
    private lazy var sharedNetworkClient: NetworkClient = {
        let client = Client(
            serverURL: try! Servers.Server1.url(),
            transport: URLSessionTransport()
        )
        return NetworkClient(client: client, apikey: apiKey)
    }()
    
    private init() {}
    
    func createNetworkClient() -> NetworkClient {
        return sharedNetworkClient
    }
    
    // MARK: - Методы для сброса кэша (опционально)
    func clearCache() async {
        await sharedNetworkClient.clearCache()
    }
}
