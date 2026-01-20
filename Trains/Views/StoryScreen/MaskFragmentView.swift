//
//  MaskFragmentView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 06.01.2026.
//

import SwiftUI

struct MaskFragmentView: View {
    private let progressBarHeight: CGFloat = 4
    private let progressBarCornerRadius: CGFloat = 2
    
    var body: some View {
        RoundedRectangle(cornerRadius: progressBarCornerRadius)
            .frame(height: progressBarHeight)
            .foregroundStyle(.white)
    }
}

struct MaskView: View {
    let numberOfSections: Int
    
    var body: some View {
        HStack {
            ForEach(0..<numberOfSections, id: \.self) { _ in
                MaskFragmentView()
            }
        }
    }
}
