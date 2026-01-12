import SwiftUI

struct MainTabView: View {
    
    enum Tab {
        case routes
        case settings
    }
    
    // MARK: - Properties
    @State private var viewModel = MainTabViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            
            // ВКЛАДКА 1: МАРШРУТЫ
            NavigationStack(path: $viewModel.routesNavigationPath) {
                RouteInputSectionView(
                    navigationPath: $viewModel.routesNavigationPath,
                    from: $viewModel.fromCity,
                    to: $viewModel.toCity
                )
                .toolbar(.hidden, for: .navigationBar)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .safeAreaInset(edge: .top, spacing: 0) {
                    if viewModel.routesNavigationPath.isEmpty {
                        StoriesStripView(
                            stories: Story.pairs.compactMap { $0.first },
                            seenIndices: viewModel.seenStoryIndices
                        ) { groupIndex in
                            viewModel.showStories(at: groupIndex)
                        }
                        .padding(.top, MainTabViewModel.Constants.storiesTopPadding)
                        .padding(.bottom, MainTabViewModel.Constants.gapToSearchBlock)
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in
                    routeView(for: route, navigationPath: $viewModel.routesNavigationPath)
                }
                .toolbar(viewModel.routesNavigationPath.isEmpty ? .visible : .hidden, for: .tabBar)
            }
            .tabItem {
                Image(viewModel.selectedTab == .routes
                      ? MainTabViewModel.Constants.routesTabActive
                      : MainTabViewModel.Constants.routesTabInactive)
            }
            .tag(Tab.routes)
            
            // ВКЛАДКА 2: НАСТРОЙКИ
            NavigationStack(path: $viewModel.settingsNavigationPath) {
                SettingsView(navigationPath: $viewModel.settingsNavigationPath)
                    .toolbar(viewModel.settingsNavigationPath.isEmpty ? .visible : .hidden, for: .tabBar)
                    .navigationDestination(for: AppRoute.self) { route in
                        settingsRouteView(for: route, navigationPath: $viewModel.settingsNavigationPath)
                    }
            }
            .tabItem {
                Image(viewModel.selectedTab == .settings
                      ? MainTabViewModel.Constants.settingsTabActive
                      : MainTabViewModel.Constants.settingsTabInactive)
            }
            .tag(Tab.settings)
        }
        // Разделитель таб-бара
        .overlay(alignment: .bottom) {
            if viewModel.shouldShowTabBarDivider(colorScheme: colorScheme) {
                Rectangle()
                    .fill(Color.ypGray)
                    .frame(height: 1.0 / UIScreen.main.scale)
                    .offset(y: -49)
            }
        }
        .fullScreenCover(isPresented: $viewModel.isShowingStories) {
            StoriesContainerView(
                groups: Story.pairs,
                startIndex: viewModel.startIndex,
                onClose: {
                    viewModel.closeStories()
                },
                onStorySeen: { index in
                    viewModel.markStoryAsSeen(index)
                }
            )
            .id(viewModel.startIndex)
        }
        .onChange(of: viewModel.isShowingStories) { oldValue, newValue in
            viewModel.onStoriesVisibilityChange(newValue: newValue)
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
                fromCity: $viewModel.fromCity,
                toCity: $viewModel.toCity
            )
            
        case .stationSearch(let context, let city, let station):
            StationSearchView(
                city: city,
                initialStation: station,
                context: context,
                navigationPath: navigationPath,
                fromCity: $viewModel.fromCity,
                toCity: $viewModel.toCity
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
