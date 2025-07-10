//
//  OnboardingLeave.swift
//  OnboardingDomain
//
//  Created by SiJongKim on 7/8/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public struct OnboardingLeave {
    public let days: Int
    public let hours: Int
    
    public init(days: Int, hours: Int) {
        self.days = days
        self.hours = hours
    }
}
