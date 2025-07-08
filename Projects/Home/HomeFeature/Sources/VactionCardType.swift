//
//  VactionCardType.swift
//  Home
//
//  Created by 김나희 on 6/29/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem

enum VacationCardType: CaseIterable, Hashable {
    
    enum ViewType {
        case long
        case short
    }

    case monday, birthday, holiday, sandwich, noholiday, friday
    case trip, good, home, koreaTrip

    var viewType: ViewType {
        switch self {
        case .trip, .good, .home, .koreaTrip:
            return .long
        default:
            return .short
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
    
    var highlight: String? {
        switch self {
        case .monday, .friday: return "일 쉬어요"
        case .birthday: return "축하드려요!"
        case .holiday: return "곧 공휴일이 다가와요"
        case .noholiday: return "이번 달엔 공휴일이 없어요"
        case .sandwich: return "일 쉴 수 있어요"
        default: return nil
        }
    }
    
    var attributedText: AttributedString? {
        switch self {
        case .birthday:
            var str = AttributedString("Happy Birthday")
            if let range = str.range(of: "Birthday") {
                str[range].foregroundColor = DS.Colors.Toast._500
            }
            return str
        case .holiday:
            var str = AttributedString("공휴일")
            // 예시: 전체를 하이라이트하지 않음
            return str
        case .friday:
            var str = AttributedString("금요일에 연차쓰고 일 쉬어요")
            if let range = str.range(of: "일 쉬어요") {
                str[range].foregroundColor = DS.Colors.Toast._500
            }
            return str
        case .monday:
            var str = AttributedString("월요일에 연차쓰고 일 쉬어요")
            if let range = str.range(of: "일 쉬어요") {
                str[range].foregroundColor = DS.Colors.Toast._500
            }
            return str
        case .sandwich:
            var str = AttributedString("주말 포함 일 쉴 수 있어요")
            if let range = str.range(of: "일 쉴 수 있어요") {
                str[range].foregroundColor = DS.Colors.Toast._500
            }
            return str
        default:
            return nil
        }
    }
}
