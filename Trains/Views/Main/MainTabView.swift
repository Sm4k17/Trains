import SwiftUI

struct MainTabView: View {
    
    private enum Constants {
        static let tabIconSize: CGFloat = 30
        static let firstTabSystemImage = "arrow.up.message.fill"
        static let secondTabAssetImage = "Vector"
    }
    
    var body: some View {
        TabView {
            NavigationStack {
                RouteInputSectionView()
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
        .withGlobalErrors()
    }
}

#Preview {
    MainTabView()
        .environment(AppState.shared)
}
