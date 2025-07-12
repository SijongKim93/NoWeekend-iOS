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
                    placeholder: "1일부터 15일 이내로 입력",
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
        // numberPad이지만 복사 붙여넣기로 텍스트 들어갈 경우에 대한 예외처리를 위함
        let filtered = newValue.filter { $0.isNumber }
        if filtered != newValue {
            inputText = filtered
        }
        
        if let day = Int(filtered) {
            if day == 0 {
                errorMessage = "1일부터 기입해주세요."
                onDaysChanged(0)
            } else if day > 15 {
                errorMessage = "최대 15일 이내까지 추천받을 수 있어요."
                onDaysChanged(day)
            } else {
                errorMessage = nil
                onDaysChanged(day)
            }
        } else if !newValue.isEmpty && filtered.isEmpty {
            errorMessage = "숫자만 입력해주세요"
            onDaysChanged(0)
        }
    }
} 
