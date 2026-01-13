//
//  CarrierInfoView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 06.01.2026.
//

import SwiftUI
import OpenAPIURLSession

struct CarrierInfoView: View {
    
    // MARK: - Constants
    
    private enum Constants {
        enum Spacing {
            static let vstack: CGFloat = 16
            static let contentPadding: CGFloat = 16
            static let fieldSpacing: CGFloat = 4
        }
        
        enum Size {
            static let logoCardHeight: CGFloat = 104
            static let logoCorner: CGFloat = 24
            static let logoMaxHeight: CGFloat = 80
            static let logoHorizontalPadding: CGFloat = 24
        }
        
        enum FontSize {
            static let title: CGFloat = 22
            static let fieldTitle: CGFloat = 17
            static let fieldValue: CGFloat = 12
        }
        
        enum Images {
            enum System {
                static let fallback = "building.2"
            }
        }
    }
    
    // MARK: - Properties
    
    @Binding var navigationPath: NavigationPath
    @State private var viewModel: CarrierInfoViewModel
    
    // MARK: - Init
    
    init(code: String, logoAssetName: String? = nil, navigationPath: Binding<NavigationPath>) {
            self._navigationPath = navigationPath
            
            let networkService = NetworkService()
            let networkClient = networkService.createNetworkClient()
            
            self._viewModel = State(initialValue: CarrierInfoViewModel(
                code: code,
                networkClient: networkClient
            ))
        }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            content
        }
        .navigationTitle("Информация о перевозчике")
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
            await viewModel.load()
        }
        .tint(.ypBlue)
    }
    
    // MARK: - Content Views
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingView
            
        case .failed(let error):
            errorView(error: error)
            
        case .loaded(let carrierData):
            loadedView(carrierData: carrierData)
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(error: Error) -> some View {
        VStack(spacing: 16) {
            Spacer()
            
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundColor(.ypRed)
                
                Text("Ошибка загрузки")
                    .font(.headline)
                    .foregroundColor(.ypBlack)
                
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundColor(.ypGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button("Повторить") {
                Task {
                    await viewModel.retry()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.ypBlue)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func loadedView(carrierData: CarrierInfoViewModel.CarrierDisplayData) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.Spacing.vstack) {
                logoCard(logoURL: carrierData.logoURL)
                
                Text(carrierData.title)
                    .font(.system(size: Constants.FontSize.title, weight: .bold))
                    .foregroundColor(.ypBlack)
                
                // Email поле
                makeField(title: "E-mail") {
                    emailContent(email: carrierData.firstEmail)
                }
                
                // Phone поле
                makeField(title: "Телефон") {
                    phoneContent(phoneNumber: carrierData.firstPhoneNumber)
                }
            }
            .padding(Constants.Spacing.contentPadding)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Email Content
    
    @ViewBuilder
    private func emailContent(email: ContactInfo.Email?) -> some View {
        if let email = email {
            if let url = email.url {
                Link(email.rawValue, destination: url)
            } else {
                Text(email.rawValue)
            }
        } else {
            Text("Не указан")
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Phone Content
    
    @ViewBuilder
    private func phoneContent(phoneNumber: ContactInfo.PhoneNumber?) -> some View {
        if let phoneNumber = phoneNumber {
            if let url = ContactFormatter.createPhoneURL(phoneNumber.rawValue) {
                Link(phoneNumber.formattedValue, destination: url)
            } else {
                Text(phoneNumber.formattedValue)
            }
        } else {
            Text("Не указан")
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Logo Card
    
    private func logoCard(logoURL: String?) -> some View {
        RoundedRectangle(cornerRadius: Constants.Size.logoCorner, style: .continuous)
            .fill(Color.ypWhiteUniversal)
            .frame(height: Constants.Size.logoCardHeight)
            .overlay {
                logoContent(logoURL: logoURL)
            }
    }
    
    @ViewBuilder
    private func logoContent(logoURL: String?) -> some View {
        if let urlString = logoURL?.trimmingCharacters(in: .whitespacesAndNewlines),
           !urlString.isEmpty {
            let fullUrlString = urlString.hasPrefix("//") ? "https:" + urlString : urlString
            
            if let url = URL(string: fullUrlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: Constants.Size.logoMaxHeight)
                    case .failure:
                        fallbackLogo
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(.horizontal, Constants.Size.logoHorizontalPadding)
            } else {
                fallbackLogo
            }
        } else {
            fallbackLogo
        }
    }
    
    private var fallbackLogo: some View {
        Image(systemName: Constants.Images.System.fallback)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: Constants.Size.logoMaxHeight)
            .foregroundColor(.ypGray)
            .padding(.horizontal, Constants.Size.logoHorizontalPadding)
    }
    
    // MARK: - Field Views
    
    private func makeField<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.fieldSpacing) {
            Text(title)
                .font(.system(size: Constants.FontSize.fieldTitle, weight: .regular))
                .foregroundColor(.ypBlack)
            
            content()
                .font(.system(size: Constants.FontSize.fieldValue, weight: .regular))
                .foregroundColor(.ypBlue)
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var navigationPath = NavigationPath()
        
        var body: some View {
            NavigationStack {
                CarrierInfoView(
                    code: "203",
                    navigationPath: $navigationPath
                )
            }
        }
    }
    
    return PreviewWrapper()
}
