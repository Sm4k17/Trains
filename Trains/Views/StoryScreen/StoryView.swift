//
//  StoryView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 06.01.2026.
//

import SwiftUI
import Combine

struct StoryView: View {
    
    struct Configuration {
        let timerTickInterval: TimeInterval
        let progressPerTick: CGFloat
        
        init(storiesCount: Int, secondsPerStory: TimeInterval = 5,
             timerTickInterval: TimeInterval = 0.05) {
            self.timerTickInterval = timerTickInterval
            self.progressPerTick = 1.0 / CGFloat(storiesCount) / secondsPerStory * (CGFloat(timerTickInterval) / CGFloat(secondsPerStory)) / CGFloat(max(storiesCount, 1))
        }
    }
    
    @Environment(\.dismiss) private var dismiss
    
    private var currentStoryIndex: Int {
        guard !stories.isEmpty else { return 0 }
        let raw = floor(progress * CGFloat(stories.count))
        let i = Int(raw)
        return max(0, min(i, stories.count - 1))
    }
    
    private var currentStory: Story? {
        guard !stories.isEmpty else { return nil }
        return stories[currentStoryIndex]
    }
    
    private let stories: [Story]
    private let configuration: Configuration
    
    @State private var progress: CGFloat = 0
    @State private var timer: Timer.TimerPublisher
    @State private var cancellable: Cancellable?
    
    private let progressBarTopPadding: CGFloat = 28
    private let closeButtonTopPadding: CGFloat = 57
    
    init(stories: [Story] = Story.all, initialIndex: Int = 0) {
        self.stories = stories
        configuration = Configuration(storiesCount: stories.count)
        timer = Timer.publish(every: configuration.timerTickInterval, on: .main, in: .common)
        
        let count = max(stories.count, 1)
        let start = max(0, min(initialIndex, count - 1))
        _progress = State(initialValue: CGFloat(start) / CGFloat(count))
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(.systemBackground).ignoresSafeArea()
            
            if let story = currentStory {
                StoriesContentView(story: story)
            }
            
            ProgressBar(numberOfSections: stories.count, progress: progress)
                .padding(.init(top: progressBarTopPadding, leading: 12, bottom: 12, trailing: 12))
            
            CloseButton(action: { dismiss() })
                .padding(.top, closeButtonTopPadding)
                .padding(.trailing, 12)
        }
        .onAppear {
            guard stories.count > 1 else { return }
            timer = Timer.publish(every: configuration.timerTickInterval, on: .main, in: .common)
            cancellable = timer.connect()
        }
        .onDisappear {
            cancellable?.cancel()
        }
        .onReceive(timer) { _ in
            timerTick()
        }
        .onTapGesture {
            nextStory()
            resetTimer()
        }
    }
    
    private func timerTick() {
        var nextProgress = progress + configuration.progressPerTick
        if nextProgress >= 1 {
            nextProgress = 0
        }
        withAnimation {
            progress = nextProgress
        }
    }
    
    private func nextStory() {
        let storiesCount = stories.count
        let currentStoryIndex = Int(progress * CGFloat(storiesCount))
        let nextStoryIndex = currentStoryIndex + 1 < storiesCount ? currentStoryIndex + 1 : 0
        withAnimation {
            progress = CGFloat(nextStoryIndex) / CGFloat(storiesCount)
        }
    }
    
    private func resetTimer() {
        cancellable?.cancel()
        timer = Timer.publish(every: configuration.timerTickInterval, on: .main, in: .common)
        cancellable = timer.connect()
    }
}
