//
//  MainTabViewModel.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 12.01.2026.
//

import SwiftUI

@Observable
final class MainTabViewModel {
    // MARK: - Properties
    var routesNavigationPath = NavigationPath()
    var settingsNavigationPath = NavigationPath()
    var selectedTab: MainTabView.Tab = .routes
    
    var fromCity: String = ""
    var toCity: String = ""
    
    // Stories
    var startIndex = 0
    var seenStoryIndices: Set<Int> = []
    var isShowingStories = false
    
    // MARK: - Constants
    struct Constants {
        static let routesTabActive = "routesTabActive"
        static let routesTabInactive = "routesTabInactive"
        static let settingsTabActive = "settingsTabActive"
        static let settingsTabInactive = "settingsTabInactive"
        static let storiesTopPadding: CGFloat = 24
        static let gapToSearchBlock: CGFloat = 44
    }
    
    // MARK: - Methods
    func showStories(at index: Int) {
        startIndex = index
        isShowingStories = true
        print("🔵 StoriesStripView tapped: groupIndex = \(index)")
    }
    
    func closeStories() {
        isShowingStories = false
        print("🔴 Closing stories")
    }
    
    func markStoryAsSeen(_ index: Int) {
        seenStoryIndices.insert(index)
        print("✅ Story seen: \(index)")
    }
    
    func onStoriesVisibilityChange(newValue: Bool) {
        if newValue {
            print("🟢 isShowingStories changed to true, startIndex = \(startIndex)")
        } else {
            print("🟡 isShowingStories changed to false")
        }
    }
    
    func shouldShowTabBarDivider(colorScheme: ColorScheme) -> Bool {
        guard colorScheme == .light else { return false }
        
        switch selectedTab {
        case .routes:
            return routesNavigationPath.isEmpty
        case .settings:
            return settingsNavigationPath.isEmpty
        }
    }
    
    func resetSearchFields() {
        fromCity = ""
        toCity = ""
    }
}
