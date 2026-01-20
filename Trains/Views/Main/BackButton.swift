//
//  BackButton.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 06.01.2026.
//

import SwiftUI

struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.ypBlack)
        }
    }
}
