//
//  NetworkService.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 13.01.2026.
//

import Foundation
import OpenAPIURLSession

final class NetworkService {
    
    private let apiKey = "17a7b5d3-ce93-4508-bdd7-5058909c0fbd"
    
    // MARK: - Shared Instance
    static let shared = NetworkService()
    
    // MARK: - Shared NetworkClient (ленивая инициализация)
    private lazy var sharedNetworkClient: NetworkClient = {
        guard let url = try? Servers.Server1.url() else {
            fatalError("Failed to create server URL. Please check server configuration.")
        }
        
        let client = Client(
            serverURL: url,
            transport: URLSessionTransport()
        )
        return NetworkClient(client: client, apikey: apiKey)
    }()
    
    // MARK: - Public Interface
    var networkClient: NetworkClient {
        sharedNetworkClient
    }
    
    private init() {}
    
    // MARK: - Cache Management
    func clearCache() async {
        await sharedNetworkClient.clearCache()
    }
}
