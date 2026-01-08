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
        }
        enum Size {
            static let bottomButtonHeight: CGFloat = 60
        }
        enum Corner {
            static let bottomButton: CGFloat = 16
        }
    }
    
    // MARK: - Properties
    
    @Binding var headerFrom: String
    @Binding var headerTo: String
    @Binding var navigationPath: NavigationPath
    
    @State private var isLoading = true
    
    // MARK: - Сервис
    
    private let carrierService: CarrierServiceProtocol
    
    // MARK: - Init
    
    init(headerFrom: Binding<String>, headerTo: Binding<String>, navigationPath: Binding<NavigationPath>) {
        self._headerFrom = headerFrom
        self._headerTo = headerTo
        self._navigationPath = navigationPath
        
        // Создаем реальный сервис
        let client = Client(
            serverURL: try! Servers.Server1.url(),
            transport: URLSessionTransport()
        )
        let apikey = "a63c3bd4-fd50-47a4-a56b-def74416d733"
        self.carrierService = CarrierService(client: client, apikey: apikey)
    }
    
    // MARK: - Mock Data
    
    private let mockItems = [
        (carrierName: "РЖД", logoSystemName: "train.side.front.car", carrierCode: "680",
         dateText: "14 января", departTime: "22:30", arriveTime: "08:15",
         durationText: "20 часов", note: "С пересадкой в Костроме"),
        
        (carrierName: "ФГК", logoSystemName: "box.truck.fill", carrierCode: "104",
         dateText: "15 января", departTime: "01:15", arriveTime: "09:00",
         durationText: "9 часов", note: nil),
        
        (carrierName: "S7 Airlines", logoSystemName: "airplane", carrierCode: "S7",
         dateText: "15 января", departTime: "12:30", arriveTime: "21:00",
         durationText: "9 часов", note: "Прямой рейс"),
        
        (carrierName: "Аэрофлот", logoSystemName: "airplane", carrierCode: "SU",
         dateText: "16 января", departTime: "08:45", arriveTime: "11:30",
         durationText: "2 часа 45 минут", note: nil),
        
        (carrierName: "ТрансКонтейнер", logoSystemName: "shippingbox.fill", carrierCode: "113",
         dateText: "17 января", departTime: "14:00", arriveTime: "06:00+1",
         durationText: "16 часов", note: "Грузовой поезд")
    ]
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: Constants.Spacing.view) {
                Text("\(headerFrom) → \(headerTo)")
                    .font(.system(size: Constants.FontSize.title, weight: .bold))
                    .foregroundColor(.ypBlack)
                    .padding(.horizontal, Constants.Spacing.horizontal)
                    .padding(.top, Constants.Spacing.titleTop)
                
                if isLoading {
                    loadingView
                } else if mockItems.isEmpty {
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
                    // Возвращаемся к RouteInputSectionView
                    navigationPath.removeLast(navigationPath.count)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            bottomButtonView
        }
        .task {
            await loadData()
        }
    }
    
    // MARK: - Main Content Views
    
    private var loadingView: some View {
        ProgressView()
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
        List(0..<mockItems.count, id: \.self) { index in
            let item = mockItems[index]
            
            Button {
                // Переход к информации о перевозчике
                navigationPath.append(
                    AppRoute.carrierInfo(
                        carrierCode: item.carrierCode,
                        logoAssetName: item.logoSystemName
                    )
                )
            } label: {
                CarrierTableRow(
                    viewModel: CarrierRowModel(
                        carrierName: item.carrierName,
                        logoSystemName: item.logoSystemName,
                        carrierCode: item.carrierCode,
                        dateText: item.dateText,
                        departTime: item.departTime,
                        arriveTime: item.arriveTime,
                        durationText: item.durationText,
                        note: item.note
                    )
                )
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(.init(top: Constants.Spacing.rowVerticalInset,
                                 leading: Constants.Spacing.rowHorizontalInset,
                                 bottom: Constants.Spacing.rowVerticalInset,
                                 trailing: Constants.Spacing.rowHorizontalInset))
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .listSectionSeparator(.hidden, edges: .all)
        .listRowSeparator(.hidden, edges: .all)
        .contentMargins(.bottom, Constants.Spacing.listBottom,
                        for: .scrollContent)
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
    
    // MARK: - Private Methods
    
    private func loadData() async {
        // Имитация загрузки данных
        isLoading = true
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
        isLoading = false
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
