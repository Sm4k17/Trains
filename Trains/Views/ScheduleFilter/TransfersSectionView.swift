//
//  TransfersSectionView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

// MARK: - TransfersOption Enum

enum TransfersOption: String, Identifiable, Hashable {
    case yes, no
    
    var id: Self { self }
    
    var title: String {
        self == .yes ? "Да" : "Нет"
    }
}

// MARK: - TransfersSectionView

struct TransfersSectionView: View {
    
    // MARK: - Properties
    
    @Binding var transfers: TransfersOption?
    
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
            ForEach([TransfersOption.yes, .no]) { option in
                transferOptionRow(for: option)
            }
        } header: {
            sectionHeader
        }
        .listSectionSpacing(0)
    }
    
    // MARK: - UI Components
    
    private func transferOptionRow(for option: TransfersOption) -> some View {
        HStack {
            Text(option.title)
                .font(.system(size: Constants.fontSize, weight: .regular))
                .foregroundColor(.ypBlack)
            Spacer()
            Image(transfers == option ? "circleOn" : "circleOff")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.ypBlack)
                .frame(width: Constants.iconSize, height: Constants.iconSize)
        }
        .contentShape(Rectangle())
        .onTapGesture { transfers = option }
        .listRowSeparator(.hidden)
        .frame(width: Constants.sectionWidth, height: Constants.rowHeight)
        .listRowInsets(EdgeInsets(
            top: 0,
            leading: Constants.hInset,
            bottom: 0,
            trailing: Constants.hInset
        ))
    }
    
    private var sectionHeader: some View {
        Text("Показывать варианты с пересадками")
            .font(.system(size: Constants.headerFontSize, weight: .bold))
            .foregroundColor(.ypBlack)
    }
}
