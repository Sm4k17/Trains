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
        
        init(storiesCount: Int, secondsPerStory: TimeInterval = 10,
             timerTickInterval: TimeInterval = 0.05) {
            self.timerTickInterval = timerTickInterval
            self.progressPerTick = CGFloat(timerTickInterval) / CGFloat(secondsPerStory * Double(max(storiesCount, 1)))
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
    
    // ДОБАВЛЕНО: Колбэк для уведомления контейнера о завершении группы
    var onGroupFinished: () -> Void
    
    @State private var progress: CGFloat = 0
    @State private var timer: Timer.TimerPublisher
    @State private var cancellable: Cancellable?
    
    private let progressBarTopPadding: CGFloat = 28
    private let closeButtonTopPadding: CGFloat = 57
    
    init(stories: [Story] = Story.all, initialIndex: Int = 0, onGroupFinished: @escaping () -> Void = {}) {
        self.stories = stories
        self.onGroupFinished = onGroupFinished
        configuration = Configuration(storiesCount: stories.count)
        timer = Timer.publish(every: configuration.timerTickInterval, on: .main, in: .common)
        
        let count = max(stories.count, 1)
        let start = max(0, min(initialIndex, count - 1))
        _progress = State(initialValue: CGFloat(start) / CGFloat(count))
    }
    
    var body: some View {
        // ... (весь UI код ZStack остается без изменений)
        ZStack(alignment: .topTrailing) {
            Color(.systemBackground).ignoresSafeArea()
            
            if let story = currentStory {
                StoriesContentView(story: story)
            }
            
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            let horizontalAmount = value.translation.width
                            let verticalAmount = value.translation.height
                            
                            if verticalAmount > 100 {
                                dismiss()
                                return
                            }
                            
                            if abs(horizontalAmount) > 50 {
                                if horizontalAmount < 0 {
                                    goToNextStory()
                                } else {
                                    goToPreviousStory()
                                }
                            } else {
                                handleTap(at: value.location)
                            }
                        }
                )
            
            VStack {
                ProgressBarView(numberOfSections: stories.count, progress: progress)
                    .frame(height: 4)
                    .padding(.horizontal, 12)
                    .padding(.top, progressBarTopPadding)
                
                Spacer()
            }
            
            CloseButtonView(action: { dismiss() })
                .padding(.top, closeButtonTopPadding)
                .padding(.trailing, 12)
        }
        .onAppear {
            guard stories.count > 0 else { return } // Исправлено: работаем даже если 1 история
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onReceive(timer) { _ in
            timerTick()
        }
    }
    
    private func startTimer() {
        timer = Timer.publish(every: configuration.timerTickInterval, on: .main, in: .common)
        cancellable = timer.connect()
    }
    
    private func stopTimer() {
        cancellable?.cancel()
    }
    
    private func restartTimer() {
        stopTimer()
        startTimer()
    }
    
    private func timerTick() {
        var nextProgress = progress + configuration.progressPerTick
        
        if nextProgress >= 1.0 {
            // Группа закончилась по таймеру
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
    
    private func handleTap(at location: CGPoint) {
        let screenWidth = UIScreen.main.bounds.width
        if location.x > screenWidth * 0.5 {
            goToNextStory()
        } else {
            goToPreviousStory()
        }
    }
    
    private func goToNextStory() {
        let nextIndex = currentStoryIndex + 1
        
        if nextIndex < stories.count {
            withAnimation(.easeInOut(duration: 0.3)) {
                progress = CGFloat(nextIndex) / CGFloat(stories.count)
            }
            restartTimer()
        } else {
            // Тап на последней истории группы — идем к следующей группе
            onGroupFinished()
        }
    }
    
    private func goToPreviousStory() {
        let prevIndex = currentStoryIndex - 1
        
        if prevIndex >= 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                progress = CGFloat(prevIndex) / CGFloat(stories.count)
            }
            restartTimer()
        }
    }
}
