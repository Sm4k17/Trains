//
//  ContactParser.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 06.01.2026.
//

import Foundation
import OSLog

final class ContactParser {
    
    // MARK: - Logger
    
    private static let logger = Logger(subsystem: "com.trains.app", category: "ContactParser")
    
    // MARK: - Main Parse Function
    
    static func parseContacts(_ text: String) -> ContactInfo {
        let cleanText = cleanHTML(text)
        let phoneNumbers = extractPhoneNumbers(from: cleanText)
        let emails = extractEmails(from: cleanText)
        
        logger.debug("Parsed contacts: \(phoneNumbers.count) phones, \(emails.count) emails")
        
        return ContactInfo(
            phoneNumbers: phoneNumbers.map { ContactInfo.PhoneNumber(rawValue: $0) },
            emails: emails.map { ContactInfo.Email(rawValue: $0) },
            cleanText: cleanText
        )
    }
    
    // MARK: - Phone Number Parsing
    
    private static func extractPhoneNumbers(from text: String) -> [String] {
        var phones: Set<String> = []
        
        let patterns = PhoneNumberPatterns.all
        
        for pattern in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern)
                let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
                
                for match in matches {
                    if let range = Range(match.range, in: text) {
                        let phone = String(text[range])
                        let cleanPhone = cleanPhoneNumber(phone)
                        
                        if isValidPhoneNumber(cleanPhone) {
                            phones.insert(cleanPhone)
                        }
                    }
                }
            } catch {
                logger.error("Failed to compile regex pattern: \(pattern), error: \(error)")
            }
        }
        
        return Array(phones).sorted()
    }
    
    // MARK: - Email Parsing
    
    private static func extractEmails(from text: String) -> [String] {
        var emails: Set<String> = []
        
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailPattern, options: .caseInsensitive)
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            for match in matches {
                if let range = Range(match.range, in: text) {
                    let email = String(text[range]).trimmingCharacters(in: .whitespaces)
                    emails.insert(email.lowercased())
                }
            }
        } catch {
            logger.error("Failed to compile email regex: \(error)")
        }
        
        return Array(emails).sorted()
    }
    
    // MARK: - Validation
    
    private static func isValidPhoneNumber(_ phone: String) -> Bool {
        let digitsOnly = phone.filter { $0.isNumber }
        
        if phone.hasPrefix("+7") {
            return digitsOnly.count == 11 // +7 и 10 цифр
        } else if phone.hasPrefix("+") {
            return digitsOnly.count >= 10 // международные номера
        } else {
            return digitsOnly.count >= 10 // локальные номера
        }
    }
    
    // MARK: - Cleaning Functions
    
    private static func cleanHTML(_ text: String) -> String {
        var cleaned = text
        
        // Убираем HTML теги
        cleaned = cleaned.replacingOccurrences(
            of: "<[^>]+>",
            with: " ",
            options: .regularExpression
        )
        
        // Заменяем HTML entities
        cleaned = replaceHTMLEntities(in: cleaned)
        
        // Убираем лишние пробелы
        cleaned = cleaned.replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private static func replaceHTMLEntities(in text: String) -> String {
        var cleaned = text
        
        let htmlEntities = [
            "&nbsp;": " ",
            "&quot;": "\"",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&#39;": "'",
            "&#34;": "\"",
            "&ndash;": "-",
            "&mdash;": "-",
            "<br>": "\n",
            "<br/>": "\n",
            "<br />": "\n"
        ]
        
        for (entity, replacement) in htmlEntities {
            cleaned = cleaned.replacingOccurrences(of: entity, with: replacement)
        }
        
        return cleaned
    }
    
    private static func cleanPhoneNumber(_ phone: String) -> String {
        // Оставляем только цифры и +
        var cleaned = phone.filter { $0.isNumber || $0 == "+" }
        
        // Если начинается с 8 и нет +, добавляем +7
        if cleaned.hasPrefix("8") && !cleaned.hasPrefix("+") {
            cleaned = "+7" + String(cleaned.dropFirst())
        }
        
        return cleaned
    }
    
    // MARK: - Patterns Enum
    
    private enum PhoneNumberPatterns {
        static let all = [
            // Международный: +X XXX XXX XXXX
            "\\+[0-9]{1,3}[\\s-]?\\(?[0-9]{1,5}\\)?[\\s-]?[0-9]{1,4}[\\s-]?[0-9]{1,4}[\\s-]?[0-9]{1,9}",
            
            // Российские 8-800
            "8[\\s-]?800[\\s-]?[0-9]{3}[\\s-]?[0-9]{3}[\\s-]?[0-9]{1}",
            "8[\\s-]?800[\\s-]?[0-9]{3}[\\s-]?[0-9]{2}[\\s-]?[0-9]{2}",
            
            // Российские с кодом
            "8[\\s-]?\\(?[0-9]{3}\\)?[\\s-]?[0-9]{3}[\\s-]?[0-9]{2}[\\s-]?[0-9]{2}",
            "\\+7[\\s-]?\\(?[0-9]{3}\\)?[\\s-]?[0-9]{3}[\\s-]?[0-9]{2}[\\s-]?[0-9]{2}",
            
            // Общие форматы
            "\\(?[0-9]{3}\\)?[\\s-]?[0-9]{3}[\\s-]?[0-9]{4}",
            "[0-9]{3}[\\s-]?[0-9]{3}[\\s-]?[0-9]{2}[\\s-]?[0-9]{2}",
            "[0-9]{3}[\\s-]?[0-9]{2}[\\s-]?[0-9]{2}",
            
            // Любая последовательность из 7+ цифр
            "\\b[0-9]{7,}\\b"
        ]
    }
}
