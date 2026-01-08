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
            
            // Контент истории
            if let story = currentStory {
                StoriesContentView(story: story)
            }
            
            // ЕДИНЫЙ ОБРАБОТЧИК ДЛЯ ТАПОВ И СВАЙПОВ
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            let horizontalAmount = value.translation.width
                            let verticalAmount = value.translation.height
                            
                            // Свайп вниз для закрытия (порог 100 пикселей)
                            if verticalAmount > 100 {
                                dismiss()
                                return
                            }
                            
                            // Если это горизонтальный свайп (перемещение > 50 пикселей)
                            if abs(horizontalAmount) > 50 {
                                if horizontalAmount < 0 {
                                    // Свайп влево - следующая история
                                    goToNextStory()
                                } else {
                                    // Свайп вправо - предыдущая история
                                    goToPreviousStory()
                                }
                            } else {
                                // Если это тап (малое перемещение)
                                handleTap(at: value.location)
                            }
                        }
                )
            
            // Прогресс-бар - ВЕРХНИЙ СЛОЙ
            VStack {
                ProgressBarView(numberOfSections: stories.count, progress: progress)
                    .frame(height: 4)
                    .padding(.horizontal, 12)
                    .padding(.top, progressBarTopPadding)
                
                Spacer()
            }
            
            // Кнопка закрытия - САМЫЙ ВЕРХНИЙ СЛОЙ
            CloseButtonView(action: { dismiss() })
                .padding(.top, closeButtonTopPadding)
                .padding(.trailing, 12)
        }
        .onAppear {
            guard stories.count > 1 else { return }
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
            // Достигли конца всех историй
            nextProgress = 1.0
            stopTimer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
        } else if nextProgress >= CGFloat(currentStoryIndex + 1) / CGFloat(stories.count) {
            // Переход к следующей истории
            nextProgress = CGFloat(currentStoryIndex + 1) / CGFloat(stories.count)
        }
        
        withAnimation(.linear(duration: configuration.timerTickInterval)) {
            progress = nextProgress
        }
    }
    
    private func handleTap(at location: CGPoint) {
        // Определяем, в какую часть экрана тапнули
        let screenWidth = UIScreen.main.bounds.width
        
        if location.x > screenWidth * 0.5 {
            // Тап в правую часть - следующая история
            goToNextStory()
        } else {
            // Тап в левую часть - предыдущая история
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
            // Последняя история - закрываем
            dismiss()
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
