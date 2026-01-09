//
//  StoriesContainerView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 09.01.2026.
//

import SwiftUI

struct StoriesContainerView: View {
    let groups: [[Story]]
    let startIndex: Int
    let onClose: () -> Void
    let onStorySeen: (Int) -> Void
    
    @State private var currentIndex: Int
    
    init(
        groups: [[Story]],
        startIndex: Int,
        onClose: @escaping () -> Void,
        onStorySeen: @escaping (Int) -> Void
    ) {
        self.groups = groups
        self.startIndex = startIndex
        self.onClose = onClose
        self.onStorySeen = onStorySeen
        _currentIndex = State(initialValue: startIndex)
    }
    
    var body: some View {
        StoryView(
            stories: groups[currentIndex],
            onGroupFinished: goToNextGroup,
            onPreviousGroupRequested: goToPreviousGroup
        )
        .id(currentIndex)
        .onAppear {
            onStorySeen(currentIndex)
        }
        .onDisappear {
            onClose()
        }
    }
    
    private func goToNextGroup() {
        let nextIndex = currentIndex + 1
        
        if nextIndex < groups.count {
            // Если есть следующая группа, переходим к ней
            currentIndex = nextIndex
            onStorySeen(nextIndex)
        } else {
            // Если это была последняя группа — закрываем контейнер
            onClose()
        }
    }
    
    private func goToPreviousGroup() {
        let prevIndex = currentIndex - 1
        
        if prevIndex >= 0 {
            // Если есть предыдущая группа, переходим к ней
            currentIndex = prevIndex
            onStorySeen(prevIndex)
        } else {
            // Если это первая группа — остаемся на ней
            // Или можно закрыть контейнер, если хотим
            // onClose()
        }
    }
}
