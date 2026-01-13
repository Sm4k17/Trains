//
//  NetworkClient.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 13.01.2026.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

actor NetworkClient {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    // MARK: - Nearest Stations
    
    func getNearestStations(lat: Double, lng: Double, distance: Int) async throws -> NearestStations {
        let response = try await client.getNearestStations(query: .init(
            apikey: apikey,
            lat: lat,
            lng: lng,
            distance: distance,
            format: "json"
        ))
        return try await response.ok.body.json
    }
    
    // MARK: - Copyright
    
    func getCopyright() async throws -> Copyright {
        let response = try await client.getCopyright(query: .init(
            apikey: apikey,
            format: .json
        ))
        return try await response.ok.body.json
    }
    
    // MARK: - Search
    
    func search(from: String, to: String, date: String? = nil) async throws -> SearchResponse {
        let response = try await client.getSearch(query: .init(
            apikey: apikey,
            from: from,
            to: to,
            format: "json",
            date: date
        ))
        return try await response.ok.body.json
    }
    
    // MARK: - Schedule
    
    func getSchedule(station: String, date: String? = nil) async throws -> ScheduleResponse {
        let response = try await client.getSchedule(query: .init(
            apikey: apikey,
            station: station,
            format: "json",
            date: date
        ))
        return try await response.ok.body.json
    }
    
    // MARK: - Thread
    
    func getThread(uid: String) async throws -> ThreadResponse {
        let response = try await client.getThread(query: .init(
            apikey: apikey,
            uid: uid,
            format: "json"
        ))
        return try await response.ok.body.json
    }
    
    // MARK: - Nearest Settlement
    
    func getNearestSettlement(lat: Double, lng: Double) async throws -> Settlement {
        let response = try await client.getNearestSettlement(query: .init(
            apikey: apikey,
            lat: lat,
            lng: lng,
            format: "json"
        ))
        return try await response.ok.body.json
    }
    
    // MARK: - Carrier
    
    func getCarrier(code: String) async throws -> CarrierResponse {
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
        return try await response.ok.body.json
    }
    
    // MARK: - Stations List
    
    func getStationsList() async throws -> String {
        let response = try await client.getStationsList(query: .init(
            apikey: apikey,
            format: "json"
        ))
        
        let body = try await response.ok.body
        return String(describing: body)
    }
}
