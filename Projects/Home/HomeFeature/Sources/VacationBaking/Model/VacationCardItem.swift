//
//  VacationCardItem.swift
//  HomeFeature
//
//  Created by 김나희 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

struct VacationCardItem: Equatable {
    let dateString: String
    let type: VacationCardType
}

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
}
