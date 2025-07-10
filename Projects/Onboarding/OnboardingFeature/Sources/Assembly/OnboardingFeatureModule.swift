//
//  OnboardingFeatureModule.swift
//  OnboardingFeature
//
//  Created by 이지훈 on 7/3/25.
//

import DIContainer
import Foundation
import OnboardingDomain
import Swinject

public enum OnboardingFeatureModule {
    public static func registerUseCases() {
        let assembly = OnboardingFeatureAssembly()
        DIContainer.shared.registerAssembly(assembly: [assembly])
    }
}
