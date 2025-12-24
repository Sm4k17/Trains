//
//  TransfersSectionView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

enum TransfersOption: String, Identifiable, Hashable {
    case yes, no
    var id: Self { self }
    var title: String { self == .yes ? "Да" : "Нет" }
}

struct TransfersSectionView: View {
    @Binding var transfers: TransfersOption?
    
    var body: some View {
        Section {
            ForEach([TransfersOption.yes, .no]) { option in
                HStack {
                    Text(option.title)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.ypBlack)
                    Spacer()
                    Image(transfers == option ? "circleOn" : "circleOff")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.ypBlack)
                        .frame(width: 24, height: 24)
                }
                .contentShape(Rectangle())
                .onTapGesture { transfers = option }
                .listRowSeparator(.hidden)
                .frame(width: 375, height: 60)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
        } header: {
            Text("Показывать варианты с пересадками")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.ypBlack)
        }
        .listSectionSpacing(0)
    }
}
