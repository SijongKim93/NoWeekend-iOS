//
//  AuthRepositoryProtocol.swift
//  OnboardingDomain
//
//  Created by 김시종 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public protocol OnboardingRepositoryInterface {
    func saveProfile(_ profile: OnboardingProfile) async throws
    func saveLeave(_ leave: OnboardingLeave) async throws
    func saveTags(_ tags: OnboardingTags) async throws
}


