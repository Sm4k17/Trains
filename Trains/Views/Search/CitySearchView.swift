//
//  CitySearchView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

struct CitySearchView: View {
    
    // MARK: - Properties
    let context: AppRoute.CitySearchContext
    let initialCity: String
    @Binding var navigationPath: NavigationPath
    @Binding var fromCity: String
    @Binding var toCity: String
    
    @State private var viewModel: CitySearchViewModel
    
    // MARK: - Initialization
    init(
        context: AppRoute.CitySearchContext,
        initialCity: String,
        navigationPath: Binding<NavigationPath>,
        fromCity: Binding<String>,
        toCity: Binding<String>
    ) {
        self.context = context
        self.initialCity = initialCity
        self._navigationPath = navigationPath
        self._fromCity = fromCity
        self._toCity = toCity
        self._viewModel = State(initialValue: CitySearchViewModel(
            context: context,
            initialCity: initialCity
        ))
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            searchField
            
            if viewModel.filteredCities.isEmpty {
                notFoundView
            } else {
                cityList
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
            static let notFound: CGFloat = 24
            static let city: CGFloat = 17
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
    
    private var cityList: some View {
        List(viewModel.filteredCities, id: \.self) { city in
            cityRow(for: city)
        }
        .listStyle(.plain)
    }
    
    private func cityRow(for city: String) -> some View {
        HStack {
            Text(city)
                .font(.system(size: Constants.FontSize.city, weight: .regular))
                .foregroundColor(.ypBlack)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.ypBlack)
                .opacity(Constants.Opacity.chevronRight)
        }
        .frame(height: Constants.Size.rowHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            navigationPath.append(viewModel.selectCity(city))
        }
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(
            top: 0,
            leading: 16,
            bottom: 0,
            trailing: 16
        ))
    }
    
    private var notFoundView: some View {
        VStack {
            Spacer()
                .frame(height: Constants.Offset.notFoundTop)
            
            Text(viewModel.notFoundText)
                .font(.system(size: Constants.FontSize.notFound, weight: .bold))
                .foregroundColor(.ypBlack)
            
            Spacer()
        }
    }
}
