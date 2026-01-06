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
        static let routesTabActive = "routesTabActive"
        static let routesTabInactive = "routesTabInactive"
        static let settingsTabActive = "settingsTabActive"
        static let settingsTabInactive = "settingsTabInactive"
    }
    
    // MARK: - Properties
    @Environment(AppState.self) private var appState
    
    // Два независимых стека навигации
    @State private var routesNavigationPath = NavigationPath()
    @State private var settingsNavigationPath = NavigationPath()
    
    @State private var fromCity: String = ""
    @State private var toCity: String = ""
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTab: Tab = .routes
    
    // MARK: - Computed Properties
    private var shouldShowTabBar: Bool {
        // Таббар показываем только:
        // 1. На главном экране (navigationPath пустой) в Routes
        // 2. В Settings всегда
        if selectedTab == .settings {
            return true
        }
        return routesNavigationPath.isEmpty
    }
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Routes
            NavigationStack(path: $routesNavigationPath) {
                RouteInputSectionView(
                    navigationPath: $routesNavigationPath,
                    from: $fromCity,
                    to: $toCity
                )
                .navigationDestination(for: AppRoute.self) { route in
                    routeView(for: route, navigationPath: $routesNavigationPath)
                        .toolbar(.hidden, for: .tabBar)
                }
                .toolbar(shouldShowTabBar ? .visible : .hidden, for: .tabBar)
            }
            .tabItem {
                Image(selectedTab == .routes
                      ? Constants.routesTabActive
                      : Constants.routesTabInactive)
            }
            .tag(Tab.routes)
            
            // Tab 2: Settings
            NavigationStack(path: $settingsNavigationPath) {
                SettingsView(
                    navigationPath: $settingsNavigationPath
                )
                .navigationDestination(for: AppRoute.self) { route in
                    if case .userAgreement = route {
                        UserAgreementWebScreen()
                            .toolbar(.hidden, for: .tabBar)
                    }
                }
                .toolbar(.visible, for: .tabBar)
            }
            .tabItem {
                Image(selectedTab == .settings
                      ? Constants.settingsTabActive
                      : Constants.settingsTabInactive)
            }
            .tag(Tab.settings)
        }
        .tint(.ypBlack)
        .safeAreaInset(edge: .bottom) {
            if colorScheme == .light && shouldShowTabBar {
                Divider()
                    .background(Color.ypGray)
                    .offset(y: -49)
            }
        }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private func routeView(for route: AppRoute, navigationPath: Binding<NavigationPath>) -> some View {
        switch route {
        case .carrierList(let from, let to):
            CarrierListView(
                headerFrom: Binding(
                    get: { from },
                    set: { _ in }
                ),
                headerTo: Binding(
                    get: { to },
                    set: { _ in }
                ),
                navigationPath: navigationPath
            )
            
        case .carrierInfo(let code, let logo):
            CarrierInfoView(
                code: code,
                logoAssetName: logo,
                navigationPath: navigationPath
            )
            
        case .scheduleFilter:
            ScheduleFilterView(
                navigationPath: navigationPath
            )
            
        case .citySearch(let context, let city, _):
            CitySearchView(
                context: context,
                initialCity: city,
                navigationPath: navigationPath,
                fromCity: $fromCity,
                toCity: $toCity
            )
            
        case .stationSearch(let context, let city, let station):
            StationSearchView(
                city: city,
                initialStation: station,
                context: context,
                navigationPath: navigationPath,
                fromCity: $fromCity,
                toCity: $toCity
            )
            
        case .userAgreement:
            EmptyView()
        }
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .environment(AppState.shared)
}
