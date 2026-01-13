//
//  StoryView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 06.01.2026.
//

import SwiftUI
import Combine

struct StoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: StoryViewModel
    
    private let progressBarTopPadding: CGFloat = 28
    private let closeButtonTopPadding: CGFloat = 57
    
    init(stories: [Story] = Story.all,
         initialIndex: Int = 0,
         onGroupFinished: @escaping () -> Void = {},
         onPreviousGroupRequested: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: StoryViewModel(
            stories: stories,
            initialIndex: initialIndex,
            onGroupFinished: onGroupFinished,
            onPreviousGroupRequested: onPreviousGroupRequested
        ))
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(.systemBackground).ignoresSafeArea()
            
            if let story = viewModel.currentStory {
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
                                    viewModel.goToNextStory()
                                } else {
                                    viewModel.goToPreviousStory()
                                }
                            } else {
                                viewModel.handleTap(
                                    at: value.location,
                                    screenWidth: UIScreen.main.bounds.width
                                )
                            }
                        }
                )
            
            VStack {
                ProgressBarView(
                    numberOfSections: viewModel.numberOfStories,
                    progress: viewModel.progress
                )
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
            guard viewModel.numberOfStories > 0 else { return }
            viewModel.startTimer()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
    }
}
