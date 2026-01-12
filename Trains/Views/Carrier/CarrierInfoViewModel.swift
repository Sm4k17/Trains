//
//  CarrierInfoViewModel.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 06.01.2026.
//

import SwiftUI
import Observation

// MARK: - ViewModel

@Observable
final class CarrierInfoViewModel {
    
    // MARK: - State
    
    enum State {
        case idle
        case loading
        case loaded(CarrierDisplayData)
        case failed(Error)
    }
    
    // MARK: - Display Data Model
    
    struct CarrierDisplayData {
        let title: String
        let logoURL: String?
        let contactInfo: ContactInfo?
        
        init(
            title: String = "Перевозчик",
            logoURL: String? = nil,
            contactInfo: ContactInfo? = nil
        ) {
            self.title = title
            self.logoURL = logoURL
            self.contactInfo = contactInfo
        }
        
        // Convenience properties
        var firstEmail: ContactInfo.Email? {
            contactInfo?.firstEmail
        }
        
        var firstPhoneNumber: ContactInfo.PhoneNumber? {
            contactInfo?.firstPhoneNumber
        }
    }
    
    // MARK: - Properties
    
    var state: State = .idle
    
    private let code: String
    private let service: CarrierServiceProtocol
    
    // MARK: - Init
    
    init(
        code: String,
        service: CarrierServiceProtocol
    ) {
        self.code = code
        self.service = service
    }
    
    // MARK: - Public Methods
    
    @MainActor
    func load() async {
        guard case .idle = state else { return }
        state = .loading
        
        do {
            let response = try await service.getCarrier(code: code)
            let displayData = processResponse(response)
            state = .loaded(displayData)
        } catch {
            state = .failed(error)
        }
    }
    
    @MainActor
    func retry() async {
        state = .idle
        await load()
    }
    
    // MARK: - Private Methods
    
    private func processResponse(_ response: CarrierResponse) -> CarrierDisplayData {
        guard let carrier = response.carrier else {
            return CarrierDisplayData()
        }
        
        let contactInfo = extractContactInfo(from: carrier)
        
        return CarrierDisplayData(
            title: carrier.title ?? "Перевозчик",
            logoURL: carrier.logo,
            contactInfo: contactInfo
        )
    }
    
    private func extractContactInfo(from carrier: Components.Schemas.Carrier) -> ContactInfo? {
        var contactStrings: [String] = []
        
        // Собираем все возможные строки с контактами
        if let email = carrier.email, !email.isEmpty {
            contactStrings.append(email)
        }
        
        if let phone = carrier.phone, !phone.isEmpty {
            contactStrings.append(phone)
        }
        
        if let contacts = carrier.contacts, !contacts.isEmpty {
            contactStrings.append(contacts)
        }
        
        // Если есть контакты, парсим их
        if !contactStrings.isEmpty {
            let combinedText = contactStrings.joined(separator: " ")
            return ContactParser.parseContacts(combinedText)
        }
        
        return nil
    }
}
