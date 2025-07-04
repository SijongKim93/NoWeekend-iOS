//
//  OnboardingDataModule.swift
//  OnboardingData
//
//  Created by 이지훈 on 7/3/25.
//

import Foundation
import Core
import OnboardingDomain

public enum OnboardingDataModule {
    public static func registerRepositories() {
        print("🚪 OnboardingData Repository 등록")
        
        // Domain Protocol을 Data 모듈에서 등록
        DIContainer.shared.container.register(OnboardingRepositoryProtocol.self) { _ in
            return OnboardingRepositoryImpl()
        }.inObjectScope(.container)
        
        print("✅ OnboardingData Repository 등록 완료")
    }
}
