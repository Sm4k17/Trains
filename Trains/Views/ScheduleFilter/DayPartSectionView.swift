//
//  DayPartSectionView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

struct DayPartSectionView: View {
    
    // MARK: - Properties
    let viewModel: ScheduleFilterViewModel
    
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
            viewModel.toggleDayPart(part)
        } label: {
            HStack {
                Text(part.rawValue)
                    .font(.system(size: Constants.fontSize, weight: .regular))
                    .foregroundStyle(.ypBlack)
                Spacer()
                Image(viewModel.hasSelectedDayPart(part) ? "excludeOn" : "excludeOff")
                    .renderingMode(.template)
                    .foregroundStyle(.ypBlack)
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
            .foregroundStyle(.ypBlack)
    }
}
