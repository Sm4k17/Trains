//
//  ProgressBarView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 06.01.2026.
//

import SwiftUI

struct ProgressBarView: View {
    let numberOfSections: Int
    let progress: CGFloat
    
    private let progressBarHeight: CGFloat = 4
    private let progressBarCornerRadius: CGFloat = 2
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: progressBarCornerRadius)
                    .frame(width: geometry.size.width, height: progressBarHeight)
                    .foregroundStyle(.white)
                
                // Progress Fill
                RoundedRectangle(cornerRadius: progressBarCornerRadius)
                    .frame(
                        width: min(progress * geometry.size.width, geometry.size.width),
                        height: progressBarHeight
                    )
                    .foregroundStyle(.blue)
            }
            .mask {
                MaskView(numberOfSections: numberOfSections)
            }
        }
    }
}
