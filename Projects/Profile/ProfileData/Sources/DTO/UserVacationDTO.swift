//
//  UserVacationDTO.swift
//  ProfileData
//
//  Created by SiJongKim on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import ProfileDomain

public struct VacationLeaveDTO: Codable {
    public let days: Int
    public let hours: Int
    
    public init(days: Int, hours: Int) {
        self.days = days
        self.hours = hours
    }
}
