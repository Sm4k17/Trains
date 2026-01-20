//
//  StoriesContentView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 06.01.2026.
//

import SwiftUI

struct StoriesContentView: View {
    let story: Story
    
    private let storyViewCornerRadius: CGFloat = 40
    private let horizontalPadding: CGFloat = 16
    private let bottomContentPadding: CGFloat = 40
    
    var body: some View {
        ZStack {
            story.backgroundColor
                .ignoresSafeArea()
            
            if let imageName = story.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .clipped()
            }
        }
        .overlay(alignment: .bottomLeading) {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(story.title)
                        .font(.system(size: 34, weight: .bold))
                        .lineLimit(2)
                        .foregroundStyle(.ypWhiteUniversal)
                    Text(story.description)
                        .font(.system(size: 20, weight: .regular))
                        .lineLimit(3)
                        .foregroundStyle(.ypWhiteUniversal)
                }
                .padding(.init(top: 0, leading: horizontalPadding, bottom: bottomContentPadding, trailing: horizontalPadding))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: storyViewCornerRadius, style: .continuous))
    }
}
