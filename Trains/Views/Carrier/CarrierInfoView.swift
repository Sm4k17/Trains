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
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CarrierInfoViewModel
    
    private let code: String
    private let service: CarrierServiceProtocol
    private let logoAssetName: String?
    
    // MARK: - Init
    
    init(code: String, service: CarrierServiceProtocol, logoAssetName: String? = nil) {
        self.code = code
        self.service = service
        self.logoAssetName = logoAssetName
        self._viewModel = State(initialValue: CarrierInfoViewModel(code: code, service: service))
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
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.ypBlack)
                }
            }
        }
        .task {
            await viewModel.load()
        }
        .tint(.ypBlue)
    }
    
    // MARK: - Content Views
    
    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingView
            
        case .failed:
            EmptyView()
            
        case .loaded(let resp):
            loadedView(carrier: resp.carrier)
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func loadedView(carrier: Components.Schemas.Carrier?) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.Spacing.vstack) {
                makeLogoCard(urlString: carrier?.logo)
                
                Text(carrier?.title ?? "Перевозчик")
                    .font(.system(size: Constants.FontSize.title, weight: .bold))
                    .foregroundColor(.ypBlack)
                
                // Email - проверяем сначала основное поле, затем извлекаем из contacts
                makeField(title: "E-mail") {
                    emailContent(for: carrier)
                }
                
                // Phone - проверяем и phone и contacts
                makeField(title: "Телефон") {
                    phoneContent(for: carrier)
                }
            }
            .padding(Constants.Spacing.contentPadding)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Email Content
    
    @ViewBuilder
    private func emailContent(for carrier: Components.Schemas.Carrier?) -> some View {
        // 1. Проверяем основное поле email
        if let email = carrier?.email, !email.isEmpty {
            makeEmailLink(email)
        }
        // 2. Если нет, извлекаем email из contacts
        else if let contacts = carrier?.contacts, !contacts.isEmpty {
            let contactInfo = ContactParser.parseContacts(contacts)
            if let firstEmail = contactInfo.emails.first {
                makeEmailLink(firstEmail)
            } else {
                Text("Не указан")
                    .foregroundStyle(.secondary)
            }
        } else {
            Text("Не указан")
                .foregroundStyle(.secondary)
        }
    }
    
    private func makeEmailLink(_ email: String) -> some View {
        if let url = URL(string: "mailto:\(email)") {
            return AnyView(Link(email, destination: url))
        } else {
            return AnyView(Text(email))
        }
    }
    
    // MARK: - Phone Content
    
    @ViewBuilder
    private func phoneContent(for carrier: Components.Schemas.Carrier?) -> some View {
        // 1. Проверяем основное поле phone
        if let phone = carrier?.phone, !phone.isEmpty {
            makePhoneLink(phone, displayText: formatPhoneForDisplay(phone))
        }
        // 2. Если нет, извлекаем телефон из contacts
        else if let contacts = carrier?.contacts, !contacts.isEmpty {
            let contactInfo = ContactParser.parseContacts(contacts)
            if let firstPhone = contactInfo.phoneNumbers.first {
                // Показываем только найденный телефон для ссылки
                makePhoneLink(firstPhone, displayText: formatPhoneForDisplay(firstPhone))
            } else {
                // Если телефона нет, показываем "Не указан"
                Text("Не указан")
                    .foregroundStyle(.secondary)
            }
        } else {
            Text("Не указан")
                .foregroundStyle(.secondary)
        }
    }
    
    private func makePhoneLink(_ phone: String, displayText: String) -> some View {
        let digitsOnly = phone.filter { $0.isNumber || $0 == "+" }
        if !digitsOnly.isEmpty, let url = URL(string: "tel:\(digitsOnly)") {
            return AnyView(Link(displayText, destination: url))
        } else {
            return AnyView(Text(displayText))
        }
    }
    
    // Форматирование телефона для отображения
    private func formatPhoneForDisplay(_ phone: String) -> String {
        let cleanedPhone = phone.filter { $0.isNumber || $0 == "+" }
        
        // Форматируем российские номера
        if cleanedPhone.hasPrefix("+7") {
            let digits = String(cleanedPhone.dropFirst(2))
            if digits.count == 10 {
                // Формат: +7 (XXX) XXX-XX-XX
                let areaCode = digits.prefix(3)
                let firstPart = digits.dropFirst(3).prefix(3)
                let secondPart = digits.dropFirst(6).prefix(2)
                let thirdPart = digits.dropFirst(8).prefix(2)
                return "+7 (\(areaCode)) \(firstPart)-\(secondPart)-\(thirdPart)"
            }
        }
        
        // Форматируем 8-800 номера
        if cleanedPhone.hasPrefix("8800") || cleanedPhone.hasPrefix("+7800") {
            let baseNumber = cleanedPhone.hasPrefix("+7800") ?
                String(cleanedPhone.dropFirst(4)) : String(cleanedPhone.dropFirst(4))
            
            if baseNumber.count == 7 {
                let part1 = baseNumber.prefix(3)
                let part2 = baseNumber.dropFirst(3).prefix(2)
                let part3 = baseNumber.dropFirst(5).prefix(2)
                return "8-800-\(part1)-\(part2)-\(part3)"
            }
        }
        
        // Возвращаем оригинальный формат, если не подходит под шаблоны
        return phone
    }
    
    // MARK: - Logo Card
    
    private func makeLogoCard(urlString: String?) -> some View {
        RoundedRectangle(cornerRadius: Constants.Size.logoCorner, style: .continuous)
            .fill(Color.ypWhiteUniversal)
            .frame(height: Constants.Size.logoCardHeight)
            .overlay {
                logoContent(urlString: urlString)
            }
    }
    
    @ViewBuilder
    private func logoContent(urlString: String?) -> some View {
        if let s = nonEmpty(urlString) {
            let fullUrlString = s.hasPrefix("//") ? "https:" + s : s
            if let url = URL(string: fullUrlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(maxHeight: 80)
                .padding(.horizontal, 24)
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
            .frame(maxHeight: 80)
            .foregroundColor(.ypGray)
            .padding(.horizontal, 24)
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
    
    // MARK: - Helper Methods
    
    private func nonEmpty(_ s: String?) -> String? {
        guard let s = s?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty else { return nil }
        return s
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        let client = Client(
            serverURL: try! Servers.Server1.url(),
            transport: URLSessionTransport()
        )
        let apikey = "a63c3bd4-fd50-47a4-a56b-def74416d733"
        let carrierService = CarrierService(client: client, apikey: apikey)
        
        CarrierInfoView(code: "203", service: carrierService, logoAssetName: "rzd")
    }
}
