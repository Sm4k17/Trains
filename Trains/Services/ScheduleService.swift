//
//  ScheduleService.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 20.11.2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

protocol ScheduleServiceProtocol: Sendable {
    func getSchedule(
        station: String,
        date: String?,
        transportTypes: String?,
        event: String?
    ) async throws -> Components.Schemas.ScheduleResponse
}

final class ScheduleService: ScheduleServiceProtocol, @unchecked Sendable {
    private let client: Client
    private let apikey: String
    
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }
    
    func getSchedule(
        station: String,
        date: String? = nil,
        transportTypes: String? = nil,
        event: String? = nil
    ) async throws -> Components.Schemas.ScheduleResponse {
        let response = try await client.getSchedule(query: .init(
            apikey: apikey,
            station: station,
            lang: "ru_RU",
            format: "json",
            date: date,
            transport_types: transportTypes,
            event: event
        ))
        return try response.ok.body.json
    }
}
