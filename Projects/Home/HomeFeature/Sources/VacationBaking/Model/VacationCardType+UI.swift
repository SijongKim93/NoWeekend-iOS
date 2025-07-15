//
//  VacationCardType+UI.swift
//  HomeFeature
//
//  Created by 김나희 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem

extension VacationCardType {
    
    var text: String {
        switch self {
        case .trip: return "해외여행 떠나요"
        case .good: return "완전 가성비 휴가예요"
        case .home: return "집에서 쉬는 것도 좋아요"
        case .koreaTrip: return "국내여행은 어때요?"
        case .monday: return "월요일에 연차쓰고"
        case .friday: return "금요일에 연차쓰고"
        case .birthday: return "생일"
        case .holiday: return "공휴일"
        case .noholiday: return "공휴일"
        case .sandwich: return "주말 포함"
        }
    }
    
    var icon: Image {
        switch self {
        case .trip: return DS.Images.imgTrip
        case .good, .friday, .monday: return DS.Images.imgStar
        case .home: return DS.Images.imgHome
        case .koreaTrip: return DS.Images.imgTrain
        case .birthday: return DS.Images.imgCake
        case .holiday, .noholiday: return DS.Images.imgKorea
        case .sandwich: return DS.Images.imgSandwich
        }
    }
    
    var attributedText: AttributedString? {
        switch self {
        case .friday:
            return createHighlightedText("금요일에 연차쓰고 일 쉬어요", highlight: "일 쉬어요")
        case .monday:
            return createHighlightedText("월요일에 연차쓰고 일 쉬어요", highlight: "일 쉬어요")
        default:
            return nil
        }
    }
    
    private func createHighlightedText(_ text: String, highlight: String) -> AttributedString {
        var str = AttributedString(text)
        if let range = str.range(of: highlight) {
            str[range].foregroundColor = DS.Colors.Toast._500
        }
        return str
    }
} 