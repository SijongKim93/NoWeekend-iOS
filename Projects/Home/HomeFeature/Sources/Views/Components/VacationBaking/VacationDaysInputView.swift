//
//  VacationDaysInputView.swift
//  HomeFeature
//
//  Created by 김나희 on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem

struct VacationDaysInputView: View {
    let vacationDays: Int
    let remainingAnnualLeave: Int
    let onDaysChanged: (Int) -> Void
    
    @State private var inputText: String = ""
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                NWTextField.userInputTextField(
                    text: $inputText,
                    suffixText: "일",
                    placeholder: "0",
                    errorMessage: $errorMessage,
                    keyboardType: .numberPad
                )
                .onChange(of: inputText) { oldValue, newValue in
                    validateInput(newValue)
                }
            }
            
            Spacer()
        }
        .onAppear {
            if vacationDays > 0 {
                inputText = "\(vacationDays)"
            }
        }
    }
    
    private func validateInput(_ newValue: String) {
        // 숫자만 입력 가능하도록 필터링
        let filtered = newValue.filter { $0.isNumber }
        if filtered != newValue {
            inputText = filtered
        }
        
        if let days = Int(filtered) {
            if days == 0 {
                errorMessage = "1일 부터 기입해주세요."
                onDaysChanged(0)
            } else if days > remainingAnnualLeave {
                errorMessage = "남은 연차에 맞춰 휴가 일수를 작성해 주세요."
                onDaysChanged(days)
            } else {
                errorMessage = nil
                onDaysChanged(days)
            }
        } else if filtered.isEmpty {
            errorMessage = nil
            onDaysChanged(0)
        }
    }
} 
