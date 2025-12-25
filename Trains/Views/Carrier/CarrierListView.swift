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
    
    @State private var showFilters = false
    @State private var isLoading = true
    
    // Мок-данные
    private let mockItems = [
        (carrierName: "РЖД", logoSystemName: "rzd",
         dateText: "14 января", departTime: "22:30", arriveTime: "08:15",
         durationText: "20 часов", note: "С пересадкой в Костроме"),
        (carrierName: "ФГК", logoSystemName: "fgk",
         dateText: "15 января", departTime: "01:15", arriveTime: "09:00",
         durationText: "9 часов", note: nil),
        (carrierName: "Урал логистика", logoSystemName: "ural",
         dateText: "15 января", departTime: "12:30", arriveTime: "21:00",
         durationText: "9 часов", note: nil)
    ]
    
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
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            }
            .padding(.horizontal, Constants.Spacing.horizontal)
            .padding(.bottom, Constants.Spacing.bottom)
            .background(Color(.systemBackground))
        }
        .onAppear {
            // Имитация загрузки
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoading = false
            }
        }
    }
    
    @ViewBuilder
    private var listView: some View {
        List(0..<mockItems.count, id: \.self) { index in
            let item = mockItems[index]
            CarrierTableRow(
                viewModel: CarrierRowViewModel(
                    carrierName: item.carrierName,
                    logoSystemName: item.logoSystemName,
                    dateText: item.dateText,
                    departTime: item.departTime,
                    arriveTime: item.arriveTime,
                    durationText: item.durationText,
                    note: item.note
                )
            )
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
}

#Preview {
    NavigationStack {
        CarrierListView(headerFrom: "Москва", headerTo: "Санкт-Петербург")
    }
}
