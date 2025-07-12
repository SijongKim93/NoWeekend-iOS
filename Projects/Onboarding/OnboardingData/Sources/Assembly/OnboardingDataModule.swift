//
//  OnboardingDataModule.swift
//  OnboardingData
//
//  Created by 이지훈 on 7/3/25.
//

import DIContainer
import Foundation
import NWNetwork
import OnboardingDomain

public enum OnboardingDataModule {
    public static func registerRepositories() {
        print("🚪 OnboardingData Repository 등록")
        
        DIContainer.shared.container.register(NWNetworkServiceProtocol.self) { _ in
            NWNetworkService()
        }.inObjectScope(.container)
        
        DIContainer.shared.container.register(OnboardingNetworkServiceInterface.self) { resolver in
            let networkService = resolver.resolve(NWNetworkServiceProtocol.self)!
            return OnboardingNetworkService(networkService: networkService)
        }.inObjectScope(.container)
        
        DIContainer.shared.container.register(OnboardingRepositoryInterface.self) { resolver in
            let service = resolver.resolve(OnboardingNetworkServiceInterface.self)!
            return OnboardingRepository(service: service)
        }.inObjectScope(.container)
        
        print("✅ OnboardingData Repository 등록 완료")
    }
}
