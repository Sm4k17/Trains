//
//  RouteInputSectionView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 24.12.2025.
//

import SwiftUI

struct RouteInputSectionView: View {
    
    @State private var from: String = ""
    @State private var to: String = ""
    
    private var hasBothInputs: Bool {
        !from.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !to.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Color.blue.cornerRadius(20)
                HStack {
                    searchCityField
                    squarePathButton
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .frame(height: 128)
            .padding(.horizontal, 16)
            
            if hasBothInputs {
                searchButton
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: hasBothInputs)
    }
    
    private var searchCityField: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Откуда", text: $from)
                        .foregroundColor(.primary)
                        .font(.system(size: 17, weight: .regular))
                    
                    Spacer().frame(height: 14)
                    
                    TextField("Куда", text: $to)
                        .foregroundColor(.primary)
                        .font(.system(size: 17, weight: .regular))
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(Color.white)
                .cornerRadius(20)
                .frame(height: 96)
            }
        }
    }
    
    private var squarePathButton: some View {
        let isDisabled = from.isEmpty && to.isEmpty
        
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                swap(&from, &to)
            }
        } label: {
            Image(systemName: "arrow.2.squarepath")
                .foregroundColor(.blue)
                .frame(width: 36, height: 36)
        }
        .background(Color.white)
        .clipShape(Circle())
        .disabled(isDisabled)
    }
    
    private var searchButton: some View {
        Button {
            // Поиск рейсов
        } label: {
            Text("Найти")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 150, height: 60)
                .background(hasBothInputs ? .blue : .gray)
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
        .disabled(!hasBothInputs)
    }
}

#Preview {
    RouteInputSectionView()
}
