//
//  ContactInfo.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 08.01.2026.
//

import Foundation

struct ContactInfo {
    let phoneNumbers: [PhoneNumber]
    let emails: [Email]
    let cleanText: String
    
    // MARK: - Nested Types
    
    struct PhoneNumber: Hashable {
        let rawValue: String
        let formattedValue: String
        
        init(rawValue: String) {
            self.rawValue = rawValue
            self.formattedValue = ContactFormatter.formatPhoneNumber(rawValue)
        }
    }
    
    struct Email: Hashable {
        let rawValue: String
        let url: URL?
        
        init(rawValue: String) {
            self.rawValue = rawValue
            self.url = URL(string: "mailto:\(rawValue)")
        }
    }
    
    // MARK: - Computed Properties
    
    var firstPhoneNumber: PhoneNumber? {
        phoneNumbers.first
    }
    
    var firstEmail: Email? {
        emails.first
    }
}
