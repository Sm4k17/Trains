//
//  CarrierRowView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

struct CarrierTableRow: View {
    
    // MARK: - Constants
    
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
            static let fallback = "building.2"
        }
    }
    
    // MARK: - Properties
    
    let viewModel: CarrierRowViewModel
    
    // MARK: - Body
    
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
    
    // MARK: - Header Content
    
    private var headerContent: some View {
        HStack(spacing: Constants.Spacing.inner) {
            logoView
                .frame(width: Constants.Size.logo, height: Constants.Size.logo)
                .background(Color.ypWhite)
                .clipShape(RoundedRectangle(cornerRadius: Constants.Corner.logo))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.carrierName)
                    .font(.system(size: Constants.FontSize.name, weight: .regular))
                    .foregroundStyle(.ypBlackUniversal)
                    .lineLimit(2)
                
                if let note = viewModel.note {
                    Text(note)
                        .font(.system(size: Constants.FontSize.note, weight: .regular))
                        .foregroundStyle(.ypRed)
                }
            }
            
            Spacer()
            
            Text(viewModel.dateText)
                .font(.system(size: Constants.FontSize.date, weight: .regular))
                .foregroundStyle(.ypBlackUniversal)
        }
    }
    
    // MARK: - Time Content
    
    private var timeContent: some View {
        HStack(spacing: Constants.Spacing.inner) {
            Text(viewModel.departTime)
                .font(.system(size: Constants.FontSize.time, weight: .regular))
                .foregroundStyle(.ypBlackUniversal)
            
            Rectangle()
                .fill(Color.ypGray)
                .frame(height: Constants.Size.lineHeight)
                .frame(maxWidth: .infinity)
            
            Text(viewModel.durationText)
                .font(.system(size: Constants.FontSize.duration, weight: .regular))
                .foregroundStyle(.ypBlackUniversal)
            
            Rectangle()
                .fill(Color.ypGray)
                .frame(height: Constants.Size.lineHeight)
                .frame(maxWidth: .infinity)
            
            Text(viewModel.arriveTime)
                .font(.system(size: Constants.FontSize.time, weight: .regular))
                .foregroundStyle(.ypBlackUniversal)
        }
    }
    
    // MARK: - Logo View
    
    @ViewBuilder
    private var logoView: some View {
        if let logoURL = viewModel.logoURL,
           let fullURL = createFullURL(from: logoURL) {
            AsyncImage(url: fullURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: Constants.Size.logo, height: Constants.Size.logo)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.Size.logo, height: Constants.Size.logo)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.Corner.logo))
                case .failure:
                    fallbackIcon
                @unknown default:
                    fallbackIcon
                }
            }
        } else {
            fallbackIcon
        }
    }
    
    private var fallbackIcon: some View {
        Image(systemName: viewModel.logoAssetName ?? Constants.Images.fallback)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundStyle(.ypBlue)
            .frame(width: Constants.Size.logo, height: Constants.Size.logo)
    }
    
    private func createFullURL(from urlString: String) -> URL? {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        let fullUrlString: String
        if trimmed.hasPrefix("//") {
            fullUrlString = "https:" + trimmed
        } else if trimmed.hasPrefix("http") {
            fullUrlString = trimmed
        } else {
            fullUrlString = "https://" + trimmed
        }
        
        return URL(string: fullUrlString)
    }
}

// MARK: - Preview

#Preview {
    CarrierTableRow(
        viewModel: CarrierRowViewModel(
            carrierName: "Аэрофлот",
            logoURL: "//company.yandex.ru/images/logo.png",
            transportType: "plane",
            carrierCode: "203",
            dateText: "14 января",
            departTime: "22:30",
            arriveTime: "08:15",
            durationText: "20 часов",
            note: "С пересадкой в Костроме"
        )
    )
    .padding(16)
}
