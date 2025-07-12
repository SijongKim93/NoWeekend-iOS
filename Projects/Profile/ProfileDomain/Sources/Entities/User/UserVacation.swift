//
//  UserVacation.swift
//  ProfileDomain
//
//  Created by SiJongKim on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public struct VacationLeave: Equatable {
    public let days: Int
    public let hours: Int
    
    public init(days: Int, hours: Int) {
        self.days = days
        self.hours = hours
    }
}
