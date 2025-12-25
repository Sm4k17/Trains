//
//  MainTabView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 24.12.2025.
//

import SwiftUI

struct MainTabView: View {
    
    @Environment(AppState.self) private var appState
    @State private var navigationPath = NavigationPath()
    @State private var fromCity: String = ""
    @State private var toCity: String = ""
    
    private enum Constants {
        static let tabIconSize: CGFloat = 30
        static let firstTabSystemImage = "arrow.up.message.fill"
        static let secondTabAssetImage = "Vector"
    }
    
    var body: some View {
        TabView {
            NavigationStack(path: $navigationPath) {
                RouteInputSectionView(navigationPath: $navigationPath, from: $fromCity, to: $toCity)
                    .navigationDestination(for: String.self) { destination in
                        if destination == "CarrierList" {
                            CarrierListView(headerFrom: $fromCity, headerTo: $toCity)
                        }
                    }
            }
            .tabItem {
                Image(systemName: Constants.firstTabSystemImage)
            }
            .tag(0)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image(Constants.secondTabAssetImage)
            }
            .tag(1)
        }
        .tint(.ypBlack)
    }
}

#Preview {
    MainTabView()
        .environment(AppState.shared)
}
