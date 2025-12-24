//
//  DayPartSectionView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

enum DayPart: String, CaseIterable, Identifiable, Hashable {
    case morning = "Утро 06:00 – 12:00"
    case day     = "День 12:00 – 18:00"
    case evening = "Вечер 18:00 – 00:00"
    case night   = "Ночь 00:00 – 06:00"
    var id: Self { self }
}

struct DayPartSectionView: View {
    @Binding var selectedParts: Set<DayPart>
    
    private let hInset: CGFloat = 16
    
    var body: some View {
        Section {
            ForEach(DayPart.allCases) { part in
                Button {
                    toggle(part)
                } label: {
                    HStack {
                        Text(part.rawValue)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.ypBlack)
                        Spacer()
                        Image(selectedParts.contains(part) ? "excludeOn" : "excludeOff")
                            .renderingMode(.template)
                            .foregroundColor(.ypBlack)
                            .frame(width: 24, height: 24)
                    }
                    .frame(width: 375, height: 60)
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
        } header: {
            Text("Время отправления")
                .textCase(nil)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
        }
        .listSectionSpacing(0)
    }
    
    private func toggle(_ part: DayPart) {
        if selectedParts.contains(part) { selectedParts.remove(part) }
        else { selectedParts.insert(part) }
    }
}
