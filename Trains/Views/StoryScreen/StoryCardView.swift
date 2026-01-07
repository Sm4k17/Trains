//
//  StoryCardView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 06.01.2026.
//

import SwiftUI

struct StoryCardView: View {
    let story: Story
    let isSeen: Bool
    
    private let storyCardWidth: CGFloat = 92
    private let storyCardHeight: CGFloat = 140
    private let storyCardCornerRadius: CGFloat = 16
    private let storyCardBorderWidth: CGFloat = 4
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageName = story.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: storyCardWidth, height: storyCardHeight)
                    .clipped()
                    .opacity(isSeen ? 0.5 : 1.0)
            } else {
                story.backgroundColor
                    .frame(width: storyCardWidth, height: storyCardHeight)
                    .opacity(isSeen ? 0.5 : 1.0)
            }
            
            Text(story.title)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.ypWhiteUniversal)
                .lineLimit(3)
                .padding(8)
        }
        .frame(width: storyCardWidth, height: storyCardHeight)
        .clipShape(RoundedRectangle(cornerRadius: storyCardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: storyCardCornerRadius, style: .continuous)
                .strokeBorder(isSeen ? .clear : .ypBlue, lineWidth: storyCardBorderWidth)
        )
    }
}

struct StoriesStripView: View {
    let stories: [Story]
    let seenIndices: Set<Int>
    let onTap: (Int) -> Void
    
    private let horizontalPadding: CGFloat = 16
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(stories.enumerated()), id: \.offset) { index, story in
                    StoryCardView(story: story, isSeen: seenIndices.contains(index))
                        .onTapGesture { onTap(index) }
                }
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
}
