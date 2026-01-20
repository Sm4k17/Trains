//
//  StationSearchView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

struct StationSearchView: View {
    
    // MARK: - Properties
    let city: String
    let initialStation: String
    let context: AppRoute.CitySearchContext
    @Binding var navigationPath: NavigationPath
    @Binding var fromCity: String
    @Binding var toCity: String
    
    @State private var viewModel: StationSearchViewModel
    
    // MARK: - Initialization
    init(
        city: String,
        initialStation: String,
        context: AppRoute.CitySearchContext,
        navigationPath: Binding<NavigationPath>,
        fromCity: Binding<String>,
        toCity: Binding<String>
    ) {
        self.city = city
        self.initialStation = initialStation
        self.context = context
        self._navigationPath = navigationPath
        self._fromCity = fromCity
        self._toCity = toCity
        self._viewModel = State(initialValue: StationSearchViewModel(
            city: city,
            initialStation: initialStation,
            context: context
        ))
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            searchField
            
            if viewModel.isLoading {
                loadingView
            } else if viewModel.filteredStations.isEmpty {
                notFoundView
            } else {
                stationList
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    navigationPath.removeLast()
                }
            }
        }
        .task {
            await viewModel.loadStations()
        }
    }
    
    // MARK: - Constants (оставляем в View)
    private struct Constants {
        enum Padding {
            static let horizontal: CGFloat = 16
            static let rowVertical: CGFloat = 4
            static let searchTop: CGFloat = 8
            static let searchBottom: CGFloat = 4
        }
        
        enum Size {
            static let rowHeight: CGFloat = 60
            static let backButton: CGFloat = 44
        }
        
        enum FontSize {
            static let notFound: CGFloat = 18
            static let station: CGFloat = 17
        }
        
        enum Opacity {
            static let chevronRight: Double = 0.6
        }
        
        enum Offset {
            static let notFoundTop: CGFloat = 228
        }
    }
    
    // MARK: - UI Components
    private var searchField: some View {
        SearchTextField(
            text: $viewModel.searchText,
            placeholder: viewModel.searchPlaceholder
        )
        .padding(.horizontal, Constants.Padding.horizontal)
        .padding(.top, Constants.Padding.searchTop)
        .padding(.bottom, Constants.Padding.searchBottom)
    }
    
    private var stationList: some View {
        List(viewModel.filteredStations) { stationItem in
            stationRow(for: stationItem.name)
        }
        .listStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: viewModel.filteredStations)
        .transition(.opacity)
        .refreshable {
            await viewModel.loadStations()
        }
    }
    
    private func stationRow(for station: String) -> some View {
        HStack {
            Text(station)
                .font(.system(size: Constants.FontSize.station, weight: .regular))
                .foregroundStyle(.ypBlack)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.ypBlack)
                .opacity(Constants.Opacity.chevronRight)
        }
        .frame(height: Constants.Size.rowHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            let fullText = viewModel.selectStation(station)
            
            if context == .from {
                fromCity = fullText
            } else {
                toCity = fullText
            }
            
            navigationPath = NavigationPath()
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(
            top: 0,
            leading: 16,
            bottom: 0,
            trailing: 16
        ))
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
                .frame(height: Constants.Offset.notFoundTop)
            
            ProgressView()
            
            Spacer()
        }
    }

    private var notFoundView: some View {
        VStack {
            Spacer()
                .frame(height: Constants.Offset.notFoundTop)
            
            Text(viewModel.notFoundText)
                .font(.system(size: Constants.FontSize.notFound, weight: .bold))
                .foregroundStyle(.ypBlack)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}
