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
    let onSelect: (String) -> Void
    
    // MARK: - State
    
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Constants
    
    private struct Constants {
        enum Padding {
            static let horizontal: CGFloat = 16
            static let rowVertical: CGFloat = 4
            static let searchTop: CGFloat = 8
            static let searchBottom: CGFloat = 4
            static let clearHit: CGFloat = 8
            static let clearTrailing: CGFloat = 14
        }
        
        enum Size {
            static let rowHeight: CGFloat = 60
            static let backButton: CGFloat = 44
        }
        
        enum CornerRadius {
            static let search: CGFloat = 10
        }
        
        enum FontSize {
            static let notFound: CGFloat = 24
            static let station: CGFloat = 17
        }
        
        enum Opacity {
            static let chevronRight: Double = 0.6
        }
        
        enum Offset {
            static let notFoundTop: CGFloat = 228
        }
        
        enum ClearButton {
            static let clearIcon = "xmark.circle.fill"
            static let textTrailingInsetForClear: CGFloat = 34
        }
    }
    
    // MARK: - Mock Data
    
    private let stations = [
        "Киевский вокзал",
        "Курский вокзал",
        "Ярославский вокзал",
        "Белорусский вокзал",
        "Савеловский вокзал",
        "Ленинградский вокзал"
    ]
    
    // MARK: - Computed Properties
    
    private var filteredStations: [String] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty
        ? stations
        : stations.filter { $0.localizedCaseInsensitiveContains(query) }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchField
                
                if filteredStations.isEmpty {
                    notFoundView
                } else {
                    stationList
                }
            }
            .navigationTitle("Выбор станции")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .toolbarRole(.editor)
        }
        .tint(.ypBlack)
    }
    
    // MARK: - UI Components
    
    private var searchField: some View {
        SearchTextField(
            text: $searchText,
            placeholder: "Введите запрос"
        )
        .padding(.horizontal, Constants.Padding.horizontal)
        .padding(.top, Constants.Padding.searchTop)
        .padding(.bottom, Constants.Padding.searchBottom)
    }
    
    private var stationList: some View {
        List(filteredStations, id: \.self) { station in
            stationRow(for: station)
        }
        .listStyle(.plain)
    }
    
    private func stationRow(for station: String) -> some View {
        HStack {
            Text(station)
                .font(.system(size: Constants.FontSize.station, weight: .regular))
                .foregroundColor(.ypBlack)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.ypBlack)
                .opacity(Constants.Opacity.chevronRight)
        }
        .frame(height: Constants.Size.rowHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect(station)
            dismiss()
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
            
            Text("Станция не найдена")
                .font(.system(size: Constants.FontSize.notFound, weight: .bold))
                .foregroundColor(.ypBlack)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        StationSearchView(city: "Москва") { station in
            print("Выбрана станция: \(station)")
        }
    }
}
