//
//  OnboardingUseCaseInterface.swift
//  OnboardingDomain
//
//  Created by SiJongKim on 7/8/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public protocol SaveProfileUseCaseInterface {
    func execute(nickname: String, birthDate: String) async throws
}

public protocol SaveLeaveUseCaseInterface {
    func execute(days: Int, hours: Int) async throws
}

public protocol SaveTagsUseCaseInterface {
    func execute(tags: [String]) async throws
}

public protocol ValidateNicknameUseCaseInterface {
    func execute(_ nickname: String) -> ValidationResult
}

public protocol ValidateBirthDateUseCaseInterface {
    func execute(_ birthDate: String) -> ValidationResult
}

public protocol ValidateRemainingDaysUseCaseInterface {
    func execute(_ days: String) -> ValidationResult
}
