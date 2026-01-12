//
//  ContactFormatter.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 12.01.2026.
//

import Foundation

enum ContactFormatter {
    
    // MARK: - Phone Number Formatting
    
    static func formatPhoneNumber(_ phone: String) -> String {
        let cleanedPhone = phone.filter { $0.isNumber || $0 == "+" }
        
        // Форматируем российские номера
        if cleanedPhone.hasPrefix("+7") {
            let digits = String(cleanedPhone.dropFirst(2))
            if digits.count == 10 {
                // Формат: +7 (XXX) XXX-XX-XX
                let areaCode = digits.prefix(3)
                let firstPart = digits.dropFirst(3).prefix(3)
                let secondPart = digits.dropFirst(6).prefix(2)
                let thirdPart = digits.dropFirst(8).prefix(2)
                return "+7 (\(areaCode)) \(firstPart)-\(secondPart)-\(thirdPart)"
            }
        }
        
        // Форматируем 8-800 номера
        if cleanedPhone.hasPrefix("8800") || cleanedPhone.hasPrefix("+7800") {
            let baseNumber = cleanedPhone.hasPrefix("+7800") ?
            String(cleanedPhone.dropFirst(4)) : String(cleanedPhone.dropFirst(4))
            
            if baseNumber.count == 7 {
                let part1 = baseNumber.prefix(3)
                let part2 = baseNumber.dropFirst(3).prefix(2)
                let part3 = baseNumber.dropFirst(5).prefix(2)
                return "8-800-\(part1)-\(part2)-\(part3)"
            }
        }
        
        // Возвращаем оригинальный формат, если не подходит под шаблоны
        return phone
    }
    
    // MARK: - URL Creation
    
    static func createPhoneURL(_ phone: String) -> URL? {
        let digitsOnly = phone.filter { $0.isNumber || $0 == "+" }
        guard !digitsOnly.isEmpty else { return nil }
        return URL(string: "tel:\(digitsOnly)")
    }
    
    static func createEmailURL(_ email: String) -> URL? {
        guard !email.isEmpty else { return nil }
        return URL(string: "mailto:\(email)")
    }
}
