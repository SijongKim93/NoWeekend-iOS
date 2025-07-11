//
//  VacationTypeSelectionView.swift
//  HomeFeature
//
//  Created by 김나희 on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem

struct VacationTypeSelectionView: View {
    let selectedTypes: Set<VacationType>
    let onTypeToggled: (VacationType) -> Void
    
    private let vacationTypePairs: [(VacationType, VacationType)] = [
        (.planning, .activeVacation),
        (.housework, .eating),
        (.rest, .selfImprovement),
        (.meal, .watching)
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            ForEach(vacationTypePairs.indices, id: \.self) { index in
                let pair = vacationTypePairs[index]
                VacationChoiceRow(
                    leftType: pair.0,
                    rightType: pair.1,
                    selectedTypes: selectedTypes,
                    onTypeToggled: onTypeToggled
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

struct VacationChoiceRow: View {
    let leftType: VacationType
    let rightType: VacationType
    let selectedTypes: Set<VacationType>
    let onTypeToggled: (VacationType) -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            NWTagButton(
                title: leftType.displayName,
                isSelected: selectedTypes.contains(leftType),
                style: .outlined,
                size: .large,
                fillsAvailableWidth: true,
                action: {
                    handleTypeSelection(leftType)
                }
            )
            .buttonStyle(PlainButtonStyle())
            
            Text("VS")
                .font(.body1)
                .foregroundColor(DS.Colors.Text.body)
                .frame(width: 30)
            
            NWTagButton(
                title: rightType.displayName,
                isSelected: selectedTypes.contains(rightType),
                style: .outlined,
                size: .large,
                fillsAvailableWidth: true,
                action: {
                    handleTypeSelection(rightType)
                }
            )
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 24)
    }
    
    private func handleTypeSelection(_ selectedType: VacationType) {
        // 같은 행의 다른 타입이 선택되어 있으면 제거
        let otherType = selectedType == leftType ? rightType : leftType
        if selectedTypes.contains(otherType) {
            onTypeToggled(otherType) // 기존 선택 해제
        }
        
        // 현재 타입 토글
        onTypeToggled(selectedType)
    }
}

 
