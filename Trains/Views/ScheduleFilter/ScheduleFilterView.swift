//
//  ScheduleFilterView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 25.12.2025.
//

import SwiftUI

struct ScheduleFilterView: View {
    
    // MARK: - Properties
    
    @State private var selectedParts: Set<DayPart> = []
    @State private var transfers: TransfersOption? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Computed Properties
    
    private var isApplyEnabled: Bool {
        !selectedParts.isEmpty && transfers != nil
    }
    
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
                backButton
            }
        }
        .safeAreaInset(edge: .bottom) {
            if isApplyEnabled {
                applyButtonView
            }
        }
    }
    
    // MARK: - Main Content
    
    private var filterList: some View {
        List {
            DayPartSectionView(selectedParts: $selectedParts)
            TransfersSectionView(transfers: $transfers)
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
    }
    
    // MARK: - UI Components
    
    private var backButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "chevron.left")
        }
    }
    
    private var applyButtonView: some View {
        HStack {
            Button("Применить") {
                dismiss()
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

// MARK: - Preview

#Preview {
    NavigationStack {
        ScheduleFilterView()
    }
}
