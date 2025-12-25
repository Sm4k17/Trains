//
//  MainTabView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 24.12.2025.
//

import SwiftUI

struct MainTabView: View {
    
    // MARK: - Tab Enum
    
    enum Tab {
        case routes
        case settings
    }
    
    // MARK: - Constants
    
    private enum Constants {
        static let tabIconSize: CGFloat = 30
        static let tabBarLineColor = Color.ypGray
        static let routesTabActive = "routesTabActive"
        static let routesTabInactive = "routesTabInactive"
        static let settingsTabActive = "settingsTabActive"
        static let settingsTabInactive = "settingsTabInactive"
    }
    
    // MARK: - Properties
    
    @Environment(AppState.self) private var appState
    @State private var navigationPath = NavigationPath()
    @State private var fromCity: String = ""
    @State private var toCity: String = ""
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTab: Tab = .routes
    
    // MARK: - Computed Properties
    
    private var isTabBarHidden: Bool {
        return !navigationPath.isEmpty
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationStack(path: $navigationPath) {
                    RouteInputSectionView(
                        navigationPath: $navigationPath,
                        from: $fromCity,
                        to: $toCity
                    )
                    .navigationDestination(for: String.self) { destination in
                        if destination == "CarrierList" {
                            CarrierListView(headerFrom: $fromCity, headerTo: $toCity)
                                .toolbar(.hidden, for: .tabBar)
                        }
                    }
                }
                .tabItem {
                    Image(selectedTab == .routes
                          ? Constants.routesTabActive
                          : Constants.routesTabInactive)
                }
                .tag(Tab.routes)
                
                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Image(selectedTab == .settings
                          ? Constants.settingsTabActive
                          : Constants.settingsTabInactive)
                }
                .tag(Tab.settings)
            }
            .tint(.ypBlack)
            
            // MARK: - TabBar Top Line
            if colorScheme == .light && !isTabBarHidden {
                Divider()
                    .background(Constants.tabBarLineColor)
                    .padding(.bottom, 49)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .environment(AppState.shared)
}
