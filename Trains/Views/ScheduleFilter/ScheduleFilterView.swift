//
//  ScheduleFilterView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

struct ScheduleFilterView: View {
    
    // MARK: - Properties
    @Binding var navigationPath: NavigationPath
    @State private var viewModel = ScheduleFilterViewModel()
    
    // MARK: - Body
    var body: some View {
        ZStack {
            filterList
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    navigationPath.removeLast()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if viewModel.isApplyEnabled {
                applyButtonView
            }
        }
    }
    
    // MARK: - Main Content
    private var filterList: some View {
        List {
            DayPartSectionView(viewModel: viewModel)
            TransfersSectionView(viewModel: viewModel)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
    }
    
    // MARK: - UI Components
    private var applyButtonView: some View {
        HStack {
            Button("Применить") {
                navigationPath.removeLast()
            }
            .font(.system(size: 17, weight: .bold))
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(Color.ypBlue)
            .foregroundColor(.ypWhiteUniversal)
            .cornerRadius(16)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }
}
