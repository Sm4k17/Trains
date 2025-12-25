//
//  DayPartSectionView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

// MARK: - DayPart Enum

enum DayPart: String, CaseIterable, Identifiable, Hashable {
    case morning = "Утро 06:00 – 12:00"
    case day     = "День 12:00 – 18:00"
    case evening = "Вечер 18:00 – 00:00"
    case night   = "Ночь 00:00 – 06:00"
    
    var id: Self { self }
}

// MARK: - DayPartSectionView

struct DayPartSectionView: View {
    
    // MARK: - Properties
    
    @Binding var selectedParts: Set<DayPart>
    
    // MARK: - Constants
    
    private struct Constants {
        static let hInset: CGFloat = 16
        static let rowHeight: CGFloat = 60
        static let iconSize: CGFloat = 24
        static let fontSize: CGFloat = 17
        static let headerFontSize: CGFloat = 24
        static let sectionWidth: CGFloat = 375
    }
    
    // MARK: - Body
    
    var body: some View {
        Section {
            ForEach(DayPart.allCases) { part in
                dayPartRow(for: part)
            }
        } header: {
            sectionHeader
        }
        .listSectionSpacing(0)
    }
    
    // MARK: - UI Components
    
    private func dayPartRow(for part: DayPart) -> some View {
        Button {
            toggle(part)
        } label: {
            HStack {
                Text(part.rawValue)
                    .font(.system(size: Constants.fontSize, weight: .regular))
                    .foregroundColor(.ypBlack)
                Spacer()
                Image(selectedParts.contains(part) ? "excludeOn" : "excludeOff")
                    .renderingMode(.template)
                    .foregroundColor(.ypBlack)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
            }
            .frame(width: Constants.sectionWidth, height: Constants.rowHeight)
        }
        .buttonStyle(.plain)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(
            top: 0,
            leading: Constants.hInset,
            bottom: 0,
            trailing: Constants.hInset
        ))
    }
    
    private var sectionHeader: some View {
        Text("Время отправления")
            .textCase(nil)
            .font(.system(size: Constants.headerFontSize, weight: .bold))
            .foregroundColor(.ypBlack)
    }
    
    // MARK: - Private Methods
    
    private func toggle(_ part: DayPart) {
        if selectedParts.contains(part) {
            selectedParts.remove(part)
        } else {
            selectedParts.insert(part)
        }
    }
}
