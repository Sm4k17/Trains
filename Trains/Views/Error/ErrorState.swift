//
//  ErrorState.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 24.12.2025.
//

import Foundation

enum ErrorState: Equatable, Identifiable {
    case offline
    case server
    case custom(String)
    
    var id: String { title }
    
    var title: String {
        switch self {
        case .offline: return "Нет интернета"
        case .server: return "Ошибка сервера"
        case .custom(let text): return text
        }
    }
    
    var assetName: String {
        switch self {
        case .offline: return "noInternet"
        case .server: return "serverError"
        case .custom: return "serverError" // изображение по умолчанию
        }
    }
}
