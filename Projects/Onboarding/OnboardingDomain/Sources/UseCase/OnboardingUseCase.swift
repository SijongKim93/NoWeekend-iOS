//
//  ValidateBirthDateUseCase.swift (개선된 버전)
//  OnboardingDomain
//
//  Created by SiJongKim on 7/8/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public class ValidateBirthDateUseCase: ValidateBirthDateUseCaseInterface {
    public init() {}
    
    public func execute(_ birthDate: String) -> ValidationResult {
        let errorMessage = "올바른 생년월일을 작성해주세요"
        
        if birthDate.isEmpty {
            return .invalid(errorMessage)
        }
        
        if birthDate.count != 8 {
            return .invalid(errorMessage)
        }
        
        if !birthDate.allSatisfy({ $0.isNumber }) {
            return .invalid(errorMessage)
        }
        
        let yearString = String(birthDate.prefix(4))
        guard let year = Int(yearString), year >= 1900, year <= 2025 else {
            return .invalid(errorMessage)
        }
        
        let monthString = String(birthDate.dropFirst(4).prefix(2))
        guard let month = Int(monthString), month >= 1, month <= 12 else {
            return .invalid(errorMessage)
        }
        
        let dayString = String(birthDate.suffix(2))
        guard let day = Int(dayString), day >= 1, day <= 31 else {
            return .invalid(errorMessage)
        }
        
        if !isValidDayForMonth(day: day, month: month, year: year) {
            return .invalid(errorMessage)
        }
        
        return .valid
    }
    
    // MARK: - Private Helper Methods
    
    private func isValidDayForMonth(day: Int, month: Int, year: Int) -> Bool {
        let daysInMonth = getDaysInMonth(month: month, year: year)
        return day <= daysInMonth
    }
    
    private func getDaysInMonth(month: Int, year: Int) -> Int {
        switch month {
        case 1, 3, 5, 7, 8, 10, 12:
            return 31
        case 4, 6, 9, 11:
            return 30
        case 2:
            return isLeapYear(year) ? 29 : 28
        default:
            return 31
        }
    }
    
    private func isLeapYear(_ year: Int) -> Bool {
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }
}
