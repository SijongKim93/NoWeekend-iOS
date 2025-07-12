//
//  OnboardingProfile.swift
//  OnboardingDomain
//
//  Created by SiJongKim on 7/8/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public struct OnboardingProfile {
    public let nickname: String
    public let birthDate: String
    
    public init(nickname: String, birthDate: String) {
        self.nickname = nickname
        self.birthDate = birthDate
    }
}
