//
//  CarrierListView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

struct CarrierListView: View {
    
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
        }
        enum Size {
            static let bottomButtonHeight: CGFloat = 60
        }
        enum Corner {
            static let bottomButton: CGFloat = 16
        }
    }
    
    let headerFrom: String
    let headerTo: String
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    @State private var showFilters = false
    @State private var isLoading = true
    @State private var carriers: [CarrierRowViewModel] = []
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: Constants.Spacing.view) {
                Text("\(headerFrom) → \(headerTo)")
                    .font(.system(size: Constants.FontSize.title, weight: .bold))
                    .foregroundColor(.ypBlack)
                    .padding(.horizontal, Constants.Spacing.horizontal)
                    .padding(.top, Constants.Spacing.titleTop)
                    .accessibilityLabel("Маршрут от \(headerFrom) до \(headerTo)")
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityLabel("Загрузка списка перевозчиков")
                } else if carriers.isEmpty {
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
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.ypBlack)
                }
                .accessibilityLabel("Назад")
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showFilters) {
            ScheduleFilterView()
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Button("Уточнить время") {
                    showFilters = true
                }
                .font(.system(size: Constants.FontSize.bottomButton, weight: .bold))
                .frame(maxWidth: .infinity, minHeight: Constants.Size.bottomButtonHeight)
                .background(Color.ypBlue)
                .foregroundColor(.ypWhiteUniversal)
                .cornerRadius(Constants.Corner.bottomButton)
                .accessibilityLabel("Уточнить время отправления")
                .accessibilityHint("Открывает экран фильтров")
            }
            .padding(.horizontal, Constants.Spacing.horizontal)
            .padding(.bottom, Constants.Spacing.bottom)
            .background(Color(.systemBackground))
        }
        .task {
            await loadCarriers()
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text("Вариантов нет")
                .font(.system(size: Constants.FontSize.emptyState, weight: .bold))
                .foregroundColor(.ypBlack)
                .accessibilityLabel("Нет доступных вариантов перевозчиков")
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var listView: some View {
        List(carriers.indices, id: \.self) { index in
            let carrier = carriers[index]
            CarrierTableRow(viewModel: carrier)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: Constants.Spacing.rowVerticalInset,
                                     leading: Constants.Spacing.rowHorizontalInset,
                                     bottom: Constants.Spacing.rowVerticalInset,
                                     trailing: Constants.Spacing.rowHorizontalInset))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Перевозчик \(carrier.carrierName), отправление \(carrier.departTime), прибытие \(carrier.arriveTime)")
                .accessibilityHint("Нажмите для просмотра деталей")
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .listSectionSeparator(.hidden, edges: .all)
        .listRowSeparator(.hidden, edges: .all)
        .contentMargins(.bottom, Constants.Spacing.listBottom,
                        for: .scrollContent)
        .accessibilityLabel("Список перевозчиков")
    }
    
    // MARK: - Методы загрузки данных
    private func loadCarriers() async {
        isLoading = true
        
        // Имитация задержки загрузки
        do {
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
            
            // Здесь будет реальная загрузка данных из API
            // Пока используем моковые данные для демонстрации
            await MainActor.run {
                // Для демонстрации разных состояний:
                // carriers = [] // Для пустого состояния
                carriers = CarrierRowViewModel.mock // Для состояния с данными
                isLoading = false
            }
            
        } catch {
            // Обработка ошибок загрузки
            await MainActor.run {
                isLoading = false
                carriers = []
            }
            
            // Показываем ошибку через AppState
            await appState.executeWithRetry {
                // Можно вызвать повторную загрузку
                await loadCarriers()
            }
        }
    }
}

#Preview("С данными") {
    NavigationStack {
        CarrierListView(headerFrom: "Москва", headerTo: "Санкт-Петербург")
            .environment(AppState.shared)
    }
}

#Preview("Без данных") {
    NavigationStack {
        CarrierListView(headerFrom: "Москва", headerTo: "Санкт-Петербург")
            .environment(AppState.shared)
            .task {
                // В превью можно сымитировать пустой список
                let view = CarrierListView(headerFrom: "Москва", headerTo: "Санкт-Петербург")
                // Не можем напрямую изменить @State, поэтому используем task
            }
    }
}
