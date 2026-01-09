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
        // Исправленная инициализация State через начальное значение
        _currentIndex = State(initialValue: startIndex)
    }
    
    var body: some View {
        // StoryView теперь принимает onGroupFinished, который вызывает наш переход
        StoryView(
            stories: groups[currentIndex],
            onGroupFinished: goToNextGroup
        )
        .id(currentIndex) // Это заставляет SwiftUI пересоздавать StoryView при смене группы
        .onAppear {
            // Отмечаем начальную группу как просмотренную
            onStorySeen(currentIndex)
        }
        .onDisappear {
            // Если экран закрыт смахиванием вниз или кнопкой Close в StoryView
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
            // Если это была последняя группа из всех 6 — закрываем контейнер
            onClose()
        }
    }
}
