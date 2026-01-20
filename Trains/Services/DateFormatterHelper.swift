//
//  DateFormatterHelper.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 16.01.2026.
//

import Foundation

enum DateFormatterHelper {
    
    // MARK: - Shared Formatters
    
    private static let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    // MARK: - Parse Methods
    
    static func parseDate(from timeString: String) -> Date? {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss",
            "HH:mm:ss"
        ]
        
        for format in formats {
            isoFormatter.dateFormat = format
            if let date = isoFormatter.date(from: timeString) {
                return date
            }
        }
        
        return nil
    }
    
    // MARK: - Format Methods
    
    static func formatTime(from timeString: String) -> String {
        guard let date = parseDate(from: timeString) else {
            return timeString
        }
        return timeFormatter.string(from: date)
    }
    
    static func formatDateFromArrivalTime(_ timeString: String) -> String {
        guard let date = parseDate(from: timeString) else {
            return timeString
        }
        
        dateFormatter.dateFormat = "d MMMM"
        return dateFormatter.string(from: date)
    }
    
    static func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)ч \(minutes)мин"
        } else if hours > 0 {
            return "\(hours)ч"
        } else {
            return "\(minutes)мин"
        }
    }
}
