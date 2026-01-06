//
//  ContactParser.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 06.01.2026.
//

import Foundation

struct ContactInfo {
    let phoneNumbers: [String]
    let emails: [String]
    let cleanText: String
}

class ContactParser {
    
    // MARK: - Main Parse Function
    
    static func parseContacts(_ text: String) -> ContactInfo {
        let cleanText = cleanHTML(text)
        let phoneNumbers = extractPhoneNumbers(from: cleanText)
        let emails = extractEmails(from: cleanText)
        
        return ContactInfo(
            phoneNumbers: phoneNumbers,
            emails: emails,
            cleanText: cleanText
        )
    }
    
    // MARK: - Phone Number Parsing
    
    private static func extractPhoneNumbers(from text: String) -> [String] {
        var phones: [String] = []
        
        // Международные форматы
        let patterns = [
            // Международный: +X XXX XXX XXXX
            "\\+[0-9]{1,3}[\\s-]?\\(?[0-9]{1,5}\\)?[\\s-]?[0-9]{1,4}[\\s-]?[0-9]{1,4}[\\s-]?[0-9]{1,9}",
            
            // Российские
            "8[\\s-]?800[\\s-]?[0-9]{3}[\\s-]?[0-9]{3}[\\s-]?[0-9]{1}", // 8-800-xxx-xxx-x (для S7: 8-800-200-000-7)
            "8[\\s-]?800[\\s-]?[0-9]{3}[\\s-]?[0-9]{2}[\\s-]?[0-9]{2}", // 8-800-xxx-xx-xx
            "8[\\s-]?\\(?[0-9]{3}\\)?[\\s-]?[0-9]{3}[\\s-]?[0-9]{2}[\\s-]?[0-9]{2}", // 8(xxx)xxx-xx-xx
            
            // Российские с кодом: +7 (XXX) XXX-XX-XX
            "\\+7[\\s-]?\\(?[0-9]{3}\\)?[\\s-]?[0-9]{3}[\\s-]?[0-9]{2}[\\s-]?[0-9]{2}",
            
            // Общий формат: (XXX) XXX-XXXX или XXX-XXX-XXXX
            "\\(?[0-9]{3}\\)?[\\s-]?[0-9]{3}[\\s-]?[0-9]{4}",
            
            // Формат с 4-мя группами цифр: XXX-XXX-XX-XX
            "[0-9]{3}[\\s-]?[0-9]{3}[\\s-]?[0-9]{2}[\\s-]?[0-9]{2}",
            
            // Формат с тире: XXX-XX-XX
            "[0-9]{3}[\\s-]?[0-9]{2}[\\s-]?[0-9]{2}",
            
            // Любая последовательность из 7+ цифр
            "\\b[0-9]{7,}\\b"
        ]
        
        for pattern in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern)
                let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
                
                for match in matches {
                    if let range = Range(match.range, in: text) {
                        let phone = String(text[range])
                        let cleanPhone = cleanPhoneNumber(phone)
                        
                        // Проверяем минимальную длину (для России минимум 10 цифр без +7)
                        if cleanPhone.hasPrefix("+7") {
                            if cleanPhone.count >= 12 { // +7 и 10 цифр
                                phones.append(cleanPhone)
                            }
                        } else if cleanPhone.count >= 10 {
                            phones.append(cleanPhone)
                        }
                    }
                }
            } catch {
                continue
            }
        }
        
        // Убираем дубликаты
        return Array(Set(phones))
    }
    
    // MARK: - Email Parsing
    
    private static func extractEmails(from text: String) -> [String] {
        var emails: [String] = []
        
        // Основной email паттерн
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailPattern, options: .caseInsensitive)
            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            for match in matches {
                if let range = Range(match.range, in: text) {
                    let email = String(text[range]).trimmingCharacters(in: .whitespaces)
                    emails.append(email)
                }
            }
        } catch {
            // Игнорируем ошибки
        }
        
        return Array(Set(emails))
    }
    
    // MARK: - Cleaning Functions
    
    private static func cleanHTML(_ text: String) -> String {
        var cleaned = text
        
        // Убираем HTML теги
        cleaned = cleaned.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
        
        // Заменяем HTML entities
        let htmlEntities = [
            "&nbsp;": " ",
            "&quot;": "\"",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&#39;": "'",
            "&ndash;": "-",
            "&mdash;": "-",
            "<br>": "\n",
            "<br/>": "\n",
            "<br />": "\n"
        ]
        
        for (entity, replacement) in htmlEntities {
            cleaned = cleaned.replacingOccurrences(of: entity, with: replacement)
        }
        
        // Убираем лишние пробелы
        cleaned = cleaned.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
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
}
