//
//  StoryViewModel.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 13.01.2026.
//

import SwiftUI
import Combine

@MainActor
final class StoryViewModel: ObservableObject {
    
    struct Configuration {
        let timerTickInterval: TimeInterval
        let progressPerTick: CGFloat
        
        init(storiesCount: Int, secondsPerStory: TimeInterval = 10,
             timerTickInterval: TimeInterval = 0.05) {
            self.timerTickInterval = timerTickInterval
            self.progressPerTick = CGFloat(timerTickInterval) / CGFloat(secondsPerStory * Double(max(storiesCount, 1)))
        }
    }
    
    @Published var progress: CGFloat = 0
    
    private let stories: [Story]
    private let configuration: Configuration
    private var timer: Timer.TimerPublisher?
    private var cancellable: Cancellable?
    
    var onGroupFinished: () -> Void
    var onPreviousGroupRequested: (() -> Void)?
    
    var currentStoryIndex: Int {
        guard !stories.isEmpty else { return 0 }
        let raw = floor(progress * CGFloat(stories.count))
        let i = Int(raw)
        return max(0, min(i, stories.count - 1))
    }
    
    var currentStory: Story? {
        guard !stories.isEmpty else { return nil }
        return stories[currentStoryIndex]
    }
    
    var numberOfStories: Int {
        stories.count
    }
    
    init(stories: [Story] = Story.all,
         initialIndex: Int = 0,
         onGroupFinished: @escaping () -> Void = {},
         onPreviousGroupRequested: (() -> Void)? = nil) {
        self.stories = stories
        self.onGroupFinished = onGroupFinished
        self.onPreviousGroupRequested = onPreviousGroupRequested
        self.configuration = Configuration(storiesCount: stories.count)
        
        let count = max(stories.count, 1)
        let start = max(0, min(initialIndex, count - 1))
        self.progress = CGFloat(start) / CGFloat(count)
    }
    
    func startTimer() {
        timer = Timer.publish(every: configuration.timerTickInterval, on: .main, in: .common)
        cancellable = timer?.sink { [weak self] _ in
            self?.timerTick()
        }
    }
    
    func stopTimer() {
        cancellable?.cancel()
        cancellable = nil
        timer = nil
    }
    
    func restartTimer() {
        stopTimer()
        startTimer()
    }
    
    private func timerTick() {
        var nextProgress = progress + configuration.progressPerTick
        
        if nextProgress >= 1.0 {
            nextProgress = 1.0
            stopTimer()
            onGroupFinished()
        } else if nextProgress >= CGFloat(currentStoryIndex + 1) / CGFloat(stories.count) {
            nextProgress = CGFloat(currentStoryIndex + 1) / CGFloat(stories.count)
        }
        
        withAnimation(.linear(duration: configuration.timerTickInterval)) {
            progress = nextProgress
        }
    }
    
    func handleTap(at location: CGPoint, screenWidth: CGFloat) {
        if location.x > screenWidth * 0.5 {
            goToNextStory()
        } else {
            goToPreviousStory()
        }
    }
    
    func goToNextStory() {
        let nextIndex = currentStoryIndex + 1
        
        if nextIndex < stories.count {
            withAnimation(.easeInOut(duration: 0.3)) {
                progress = CGFloat(nextIndex) / CGFloat(stories.count)
            }
            restartTimer()
        } else {
            onGroupFinished()
        }
    }
    
    func goToPreviousStory() {
        let prevIndex = currentStoryIndex - 1
        
        if prevIndex >= 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                progress = CGFloat(prevIndex) / CGFloat(stories.count)
            }
            restartTimer()
        } else {
            onPreviousGroupRequested?()
        }
    }
}
