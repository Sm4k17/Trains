//
//  RouteInputSectionViewModel.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 12.01.2026.
//

import SwiftUI

@Observable
final class RouteInputSectionViewModel {
    
    // MARK: - Constants
    enum Constants {
        enum Padding {
            static let horizontal: CGFloat = 16.0
            static let vertical: CGFloat = 16.0
            static let leading: CGFloat = 20.0
        }
        
        enum Size {
            static let viewHeight: CGFloat = 128.0
            static let button: CGFloat = 36.0
            static let searchButtonWidth: CGFloat = 150.0
            static let searchButtonHeight: CGFloat = 60.0
            static let fieldHeight: CGFloat = 96.0
            static let spacerHeight: CGFloat = 14.0
        }
        
        enum Spacing {
            static let view: CGFloat = 12.0
            static let field: CGFloat = 8.0
        }
        
        enum FontSize {
            static let label: CGFloat = 17.0
            static let labelButton: CGFloat = 17
        }
        
        enum Colors {
            static let textField: Color = .ypGray
            static let squarepathButton: Color = .ypWhiteUniversal
            static let cardBackground: Color = .ypWhiteUniversal
            static let searchButtonBackground: Color = .ypBlue
        }
        
        enum CornerRadius {
            static let view: Double = 20.0
            static let searchButton: CGFloat = 16.0
        }
        
        enum Animation {
            static let duration: Double = 0.2
            static let swapSpringResponse: Double = 0.25
            static let swapSpringDamping: Double = 0.9
        }
        
        enum Placeholder {
            static let from = "Откуда"
            static let to   = "Куда"
        }
        
        enum Titles {
            static let searchButton = "Найти"
        }
        
        enum Images {
            enum System {
                static let squarePathButton = "arrow.2.squarepath"
            }
        }
    }
    
    // MARK: - Static Methods
    static func hasBothInputs(from: String, to: String) -> Bool {
        !from.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !to.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    static func extractCity(from text: String) -> String {
        // Извлекаем название города из строки "Город (Станция)"
        if let range = text.range(of: " (") {
            return String(text[..<range.lowerBound])
        }
        return text
    }
    
    static func getCityForSearch(_ text: String) -> String {
        extractCity(from: text)
    }
}
