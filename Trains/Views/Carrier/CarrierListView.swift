//
//  CarrierListView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI
import OpenAPIURLSession

struct CarrierListView: View {
    
    // MARK: - Constants
    
    private enum Constants {
        enum Spacing {
            static let view: CGFloat = 12
            static let horizontal: CGFloat = 16
            static let titleTop: CGFloat = 12
            static let rowVerticalInset: CGFloat = 8
            static let rowHorizontalInset: CGFloat = 16
            static let listBottom: CGFloat = 10
            static let bottom: CGFloat = 24
        }
        enum FontSize {
            static let title: CGFloat = 24
            static let bottomButton: CGFloat = 17
            static let emptyState: CGFloat = 24
            static let error: CGFloat = 16
        }
        enum Size {
            static let bottomButtonHeight: CGFloat = 60
        }
        enum Corner {
            static let bottomButton: CGFloat = 16
        }
    }
    
    // MARK: - Properties
    
    @State private var viewModel: CarrierListViewModel
    @Binding var headerFrom: String
    @Binding var headerTo: String
    @Binding var navigationPath: NavigationPath
    
    // MARK: - Initialization
    
    init(
        headerFrom: Binding<String>,
        headerTo: Binding<String>,
        navigationPath: Binding<NavigationPath>
    ) {
        self._headerFrom = headerFrom
        self._headerTo = headerTo
        self._navigationPath = navigationPath
        
        // Создаем реальный сервис
        let client = Client(
            serverURL: try! Servers.Server1.url(),
            transport: URLSessionTransport()
        )
        let apikey = "a63c3bd4-fd50-47a4-a56b-def74416d733"
        let carrierService = CarrierService(client: client, apikey: apikey)
        
        self._viewModel = State(initialValue: CarrierListViewModel(
            fromCity: headerFrom.wrappedValue,
            toCity: headerTo.wrappedValue,
            carrierService: carrierService
        ))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: Constants.Spacing.view) {
                Text(viewModel.headerTitle)
                    .font(.system(size: Constants.FontSize.title, weight: .bold))
                    .foregroundColor(.ypBlack)
                    .padding(.horizontal, Constants.Spacing.horizontal)
                    .padding(.top, Constants.Spacing.titleTop)
                
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(error)
                } else if viewModel.showEmptyState {
                    emptyStateView
                } else {
                    listView
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    navigationPath.removeLast()
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            bottomButtonView
        }
        .task {
            await viewModel.loadCarriers()
        }
    }
    
    // MARK: - Main Content Views
    
    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.ypRed)
            
            Text("Ошибка")
                .font(.system(size: Constants.FontSize.error, weight: .semibold))
                .foregroundColor(.ypBlack)
            
            Text(message)
                .font(.system(size: Constants.FontSize.error, weight: .regular))
                .foregroundColor(.ypGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text("Вариантов нет")
                .font(.system(size: Constants.FontSize.emptyState, weight: .bold))
                .foregroundColor(.ypBlack)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var listView: some View {
        List(viewModel.carriers.indices, id: \.self) { index in
            let carrier = viewModel.carriers[index]
            
            Button {
                if let info = viewModel.getCarrierInfo(for: index) {
                    navigationPath.append(
                        AppRoute.carrierInfo(
                            carrierCode: info.code,
                            logoAssetName: info.logoName
                        )
                    )
                }
            } label: {
                CarrierTableRow(viewModel: carrier)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(.init(
                top: Constants.Spacing.rowVerticalInset,
                leading: Constants.Spacing.rowHorizontalInset,
                bottom: Constants.Spacing.rowVerticalInset,
                trailing: Constants.Spacing.rowHorizontalInset
            ))
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .listSectionSeparator(.hidden, edges: .all)
        .listRowSeparator(.hidden, edges: .all)
        .contentMargins(.bottom, Constants.Spacing.listBottom, for: .scrollContent)
    }
    
    // MARK: - UI Components
    
    private var bottomButtonView: some View {
        HStack {
            Button("Уточнить время") {
                navigationPath.append(AppRoute.scheduleFilter)
            }
            .font(.system(size: Constants.FontSize.bottomButton, weight: .bold))
            .frame(maxWidth: .infinity, minHeight: Constants.Size.bottomButtonHeight)
            .background(Color.ypBlue)
            .foregroundColor(.ypWhiteUniversal)
            .cornerRadius(Constants.Corner.bottomButton)
        }
        .padding(.horizontal, Constants.Spacing.horizontal)
        .padding(.bottom, Constants.Spacing.bottom)
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var navigationPath = NavigationPath()
        @State private var from = "Москва"
        @State private var to = "Санкт-Петербург"
        
        var body: some View {
            NavigationStack {
                CarrierListView(
                    headerFrom: $from,
                    headerTo: $to,
                    navigationPath: $navigationPath
                )
            }
        }
    }
    
    return PreviewWrapper()
}
