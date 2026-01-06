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
        case loaded(CarrierResponse)
        case failed(Error)
    }
    
    // MARK: - Properties
    
    var state: State = .idle
    
    private let code: String
    private let service: CarrierServiceProtocol
    
    // MARK: - Init
    
    init(code: String, service: CarrierServiceProtocol) {
        self.code = code
        self.service = service
    }
    
    // MARK: - Public Methods
    
    func load() async {
        guard case .idle = state else { return }
        state = .loading
        
        do {
            let resp = try await service.getCarrier(code: code)
            state = .loaded(resp)
        } catch {
            state = .failed(error)
        }
    }
    
    func retry() {
        state = .idle
    }
}
