//
//  CarrierRowView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

struct CarrierTableRow: View {
    
    private enum Constants {
        enum Spacing {
            static let outer: CGFloat = 10
            static let inner: CGFloat = 12
            static let rowPadding: CGFloat = 14
        }
        enum Size {
            static let rowHeight: CGFloat = 104
            static let logo: CGFloat = 38
            static let lineHeight: CGFloat = 1
            static let lineWidth: CGFloat = 1
        }
        enum Corner {
            static let logo: CGFloat = 12
            static let card: CGFloat = 24
        }
        enum Opacity {
            static let card: CGFloat = 0.3
        }
        enum FontSize {
            static let name: CGFloat = 17
            static let time: CGFloat = 17
            static let date: CGFloat = 12
            static let duration: CGFloat = 12
            static let note: CGFloat = 12
        }
        enum Images {
            enum System {
                static let fallback = "building.2"
            }
        }
    }
    
    let viewModel: CarrierRowViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.outer) {
            headerContent
            timeContent
        }
        .padding(Constants.Spacing.rowPadding)
        .frame(height: Constants.Size.rowHeight)
        .background(
            RoundedRectangle(cornerRadius: Constants.Corner.card)
                .fill(Color.ypLightGray)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Corner.card)
                .stroke(Color.ypGray.opacity(Constants.Opacity.card), lineWidth: Constants.Size.lineWidth)
        )
    }
    
    private var headerContent: some View {
        HStack(spacing: Constants.Spacing.inner) {
            logoView
                .frame(width: Constants.Size.logo, height: Constants.Size.logo)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: Constants.Corner.logo))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.carrierName)
                    .font(.system(size: Constants.FontSize.name, weight: .regular))
                    .foregroundColor(.ypBlackUniversal)
                
                if let note = viewModel.note {
                    Text(note)
                        .font(.system(size: Constants.FontSize.note, weight: .regular))
                        .foregroundColor(.ypRed)
                }
            }
            
            Spacer()
            
            Text(viewModel.dateText)
                .font(.system(size: Constants.FontSize.date, weight: .regular))
                .foregroundColor(.ypBlackUniversal)
        }
    }
    
    private var timeContent: some View {
        HStack(spacing: Constants.Spacing.inner) {
            departTimeText
            line
            durationText
            line
            arriveTimeText
        }
    }
    
    private var departTimeText: some View {
        Text(viewModel.departTime)
            .font(.system(size: Constants.FontSize.time, weight: .regular))
            .foregroundColor(.ypBlackUniversal)
    }
    
    private var arriveTimeText: some View {
        Text(viewModel.arriveTime)
            .font(.system(size: Constants.FontSize.time, weight: .regular))
            .foregroundColor(.ypBlackUniversal)
    }
    
    private var durationText: some View {
        Text(viewModel.durationText)
            .font(.system(size: Constants.FontSize.duration, weight: .regular))
            .foregroundColor(.ypBlackUniversal)
    }
    
    private var line: some View {
        Rectangle()
            .fill(Color.ypGray)
            .frame(height: Constants.Size.lineHeight)
            .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var logoView: some View {
        if let name = viewModel.logoSystemName, UIImage(named: name) != nil {
            Image(name)
                .resizable()
                .scaledToFill()
                .clipped()
        } else if let name = viewModel.logoSystemName {
            Image(systemName: name)
                .resizable()
                .scaledToFill()
                .clipped()
        } else {
            Image(systemName: Constants.Images.System.fallback)
                .resizable()
                .scaledToFill()
                .clipped()
        }
    }
}

#Preview {
    CarrierTableRow(
        viewModel: CarrierRowViewModel(
            carrierName: "РЖД",
            logoSystemName: "train.side.front.car",
            dateText: "14 января",
            departTime: "22:30",
            arriveTime: "08:15",
            durationText: "20 часов",
            note: "С пересадкой в Костроме"
        )
    )
    .padding(16)
}
