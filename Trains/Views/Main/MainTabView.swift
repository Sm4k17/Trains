import SwiftUI

struct MainTabView: View {
    
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
        
        // Отступы
        static let storiesTopPadding: CGFloat = 24
        static let gapToSearchBlock: CGFloat = 44
    }
    
    // MARK: - Properties
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var routesNavigationPath = NavigationPath()
    @State private var settingsNavigationPath = NavigationPath()
    
    @State private var fromCity: String = ""
    @State private var toCity: String = ""
    @State private var selectedTab: Tab = .routes
    
    // Stories
    @State private var startIndex = 0
    @State private var seenStoryIndices: Set<Int> = []
    @State private var isShowingStories = false
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // ВКЛАДКА 1: МАРШРУТЫ
            NavigationStack(path: $routesNavigationPath) {
                RouteInputSectionView(
                    navigationPath: $routesNavigationPath,
                    from: $fromCity,
                    to: $toCity
                )
                .toolbar(.hidden, for: .navigationBar)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .safeAreaInset(edge: .top, spacing: 0) {
                    if routesNavigationPath.isEmpty {
                        StoriesStripView(
                            stories: Story.pairs.compactMap { $0.first },
                            seenIndices: seenStoryIndices
                        ) { groupIndex in
                            print("🔵 StoriesStripView tapped: groupIndex = \(groupIndex)")
                            print("🔵 Setting startIndex from \(self.startIndex) to \(groupIndex)")
                            self.startIndex = groupIndex
                            print("🔵 Setting isShowingStories to true")
                            self.isShowingStories = true
                            print("🔵 After setting: startIndex = \(self.startIndex), isShowingStories = \(self.isShowingStories)")
                        }
                        .padding(.top, Constants.storiesTopPadding)
                        .padding(.bottom, Constants.gapToSearchBlock)
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in
                    routeView(for: route, navigationPath: $routesNavigationPath)
                }
                .toolbar(routesNavigationPath.isEmpty ? .visible : .hidden, for: .tabBar)
            }
            .tabItem {
                Image(selectedTab == .routes
                      ? Constants.routesTabActive
                      : Constants.routesTabInactive)
            }
            .tag(Tab.routes)
            
            // ВКЛАДКА 2: НАСТРОЙКИ
            NavigationStack(path: $settingsNavigationPath) {
                SettingsView(navigationPath: $settingsNavigationPath)
                    .toolbar(settingsNavigationPath.isEmpty ? .visible : .hidden, for: .tabBar)
                    .navigationDestination(for: AppRoute.self) { route in
                        settingsRouteView(for: route, navigationPath: $settingsNavigationPath)
                    }
            }
            .tabItem {
                Image(selectedTab == .settings
                      ? Constants.settingsTabActive
                      : Constants.settingsTabInactive)
            }
            .tag(Tab.settings)
        }
        // Разделитель таб-бара
        .overlay(alignment: .bottom) {
            let isRoutesEmpty = routesNavigationPath.isEmpty
            let isSettingsEmpty = settingsNavigationPath.isEmpty
            
            // Проверяем, что мы на главных экранах вкладок, а не внутри UserAgreement
            if colorScheme == .light && (
                (selectedTab == .settings && isSettingsEmpty) ||
                (selectedTab == .routes && isRoutesEmpty)
            ) {
                Rectangle()
                    .fill(Color.ypGray)
                    .frame(height: 1.0 / UIScreen.main.scale)
                    .offset(y: -49)
            }
        }
        .fullScreenCover(isPresented: $isShowingStories) {
            StoriesContainerView(
                groups: Story.pairs,
                startIndex: startIndex,
                onClose: {
                    print("🔴 Closing stories")
                    isShowingStories = false
                },
                onStorySeen: { index in
                    print("✅ Story seen: \(index)")
                    seenStoryIndices.insert(index)
                }
            )
            .id(startIndex)
        }
        .onChange(of: isShowingStories) { oldValue, newValue in
            if newValue {
                print("🟢 isShowingStories changed to true, startIndex = \(startIndex)")
            } else {
                print("🟡 isShowingStories changed to false")
            }
        }
    }
    
    // MARK: - Routes Tab Route Builder
    
    @ViewBuilder
    private func routeView(
        for route: AppRoute,
        navigationPath: Binding<NavigationPath>
    ) -> some View {
        switch route {
            
        case .carrierList(let from, let to):
            CarrierListView(
                headerFrom: .constant(from),
                headerTo: .constant(to),
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
            UserAgreementWebScreen()
                .toolbar(.hidden, for: .tabBar)
        }
    }
    
    // MARK: - Settings Tab Route Builder
    
    @ViewBuilder
    private func settingsRouteView(
        for route: AppRoute,
        navigationPath: Binding<NavigationPath>
    ) -> some View {
        switch route {
        case .userAgreement:
            UserAgreementWebScreen()
                .toolbar(.hidden, for: .tabBar)
            
        default:
            // Для других роутов (если они понадобятся в Settings)
            EmptyView()
        }
    }
}
