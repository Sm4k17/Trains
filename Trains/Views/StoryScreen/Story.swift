//
//  Story.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 06.01.2026.
//

import SwiftUI

struct Story: Identifiable {
    let id: Int
    let backgroundColor: Color
    let title: String
    let description: String
    let imageName: String?
    
    static let story1 = Story(
        id: 1,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        imageName: "1"
    )
    
    static let story2 = Story(
        id: 2,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2 Text2, Text2 Text2 Text2 Text2 ",
        imageName: "2"
    )
    
    static let story3 = Story(
        id: 3,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 ",
        imageName: "3"
    )
    
    static let story4 = Story(
        id: 4,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 ",
        imageName: "4"
    )
    
    static let story5 = Story(
        id: 5,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 ",
        imageName: "5"
    )
    
    static let story6 = Story(
        id: 6,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 ",
        imageName: "6"
    )
    
    static let story7 = Story(
        id: 7,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 ",
        imageName: "7"
    )
    
    static let story8 = Story(
        id: 8,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 ",
        imageName: "8"
    )
    
    static let story9 = Story(
        id: 9,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 ",
        imageName: "9"
    )
    
    static let story10 = Story(
        id: 10,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 ",
        imageName: "10"
    )
    
    static let story11 = Story(
        id: 11,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 ",
        imageName: "11"
    )
    
    static let story12 = Story(
        id: 12,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 ",
        imageName: "12"
    )
    
    static let story13 = Story(
        id: 13,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 ",
        imageName: "13"
    )
    
    static let story14 = Story(
        id: 14,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 ",
        imageName: "14"
    )
    
    static let story15 = Story(
        id: 15,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 ",
        imageName: "15"
    )
    
    static let story16 = Story(
        id: 16,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 ",
        imageName: "16"
    )
    
    static let story17 = Story(
        id: 17,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 ",
        imageName: "17"
    )
    
    static let story18 = Story(
        id: 18,
        backgroundColor: Color(.systemBackground),
        title: "Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 Text1 ",
        description: "Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 Text3 ",
        imageName: "18"
    )
}

extension Story {
    static let all: [Story] = [
        .story1, .story2, .story3, .story4, .story5,
        .story6, .story7, .story8, .story9, .story10,
        .story11, .story12, .story13, .story14, .story15,
        .story16, .story17, .story18
    ]
    
    static var odd: [Story] {
        stride(from: 0, to: all.count, by: 2).map { all[$0] }
    }
    
    static var pairs: [[Story]] {
        stride(from: 0, to: all.count - 1, by: 2).map { [all[$0], all[$0 + 1]] }
    }
}
