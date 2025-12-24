//
//  TrainsApp.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 17.11.2025.
//

import SwiftUI

@main
struct TrainsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Больше не нужно передавать environment здесь
                // AppState.shared будет доступен через GlobalErrorPresenter
                .withGlobalErrors()
        }
    }
}
