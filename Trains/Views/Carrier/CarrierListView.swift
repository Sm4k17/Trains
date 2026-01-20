//
//  CarrierListView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

struct CarrierListView: View {
    
    // MARK: - Constants
    
    private enum Constants {
        enum Spacing {
            static let view: CGFloat = 12
            static let horizontal: CGFloat = 16
            static let titleTop: CGFloat = 12
            static let rowVerticalInset: CGFloat = 4
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
        
        let networkClient = NetworkService.shared.networkClient
        
        self._viewModel = State(initialValue: CarrierListViewModel(
            fromText: headerFrom.wrappedValue,
            toText: headerTo.wrappedValue,
            networkClient: networkClient
        ))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: Constants.Spacing.view) {
                Text(viewModel.headerTitle)
                    .font(.system(size: Constants.FontSize.title, weight: .bold))
                    .foregroundStyle(.ypBlack)
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
        .onAppear {
            viewModel.applySavedFilter()
        }
        .onChange(of: ScheduleFilterViewModel.savedFilter) { oldValue, newValue in
            // Применяем новый фильтр и перезагружаем данные
            viewModel.applySavedFilter()
            viewModel.reloadWithCurrentFilter()
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
                .foregroundStyle(.ypRed)
            
            Text("Ошибка")
                .font(.system(size: Constants.FontSize.error, weight: .semibold))
                .foregroundStyle(.ypBlack)
            
            Text(message)
                .font(.system(size: Constants.FontSize.error, weight: .regular))
                .foregroundStyle(.ypGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text(viewModel.hasActiveFilter ?
                 "Нет подходящих маршрутов" : "Маршрутов не найдено")
            .font(.system(size: Constants.FontSize.emptyState, weight: .bold))
            .foregroundStyle(.ypBlack)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var listView: some View {
        List {
            ForEach(Array(viewModel.carriers.enumerated()), id: \.element.id) { index, carrier in
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
            Button {
                navigationPath.append(AppRoute.scheduleFilter)
            } label: {
                HStack(spacing: 8) {
                    Text("Уточнить время")
                        .font(.system(size: Constants.FontSize.bottomButton, weight: .bold))
                    
                    if ScheduleFilterViewModel.savedFilter.isActive {
                        Circle()
                            .fill(Color.ypRed)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: Constants.Size.bottomButtonHeight)
            .background(Color.ypBlue)
            .foregroundStyle(.ypWhiteUniversal)
            .cornerRadius(Constants.Corner.bottomButton)
        }
        .padding(.horizontal, Constants.Spacing.horizontal)
        .padding(.bottom, Constants.Spacing.bottom)
        .background(Color(.systemBackground))
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
}
