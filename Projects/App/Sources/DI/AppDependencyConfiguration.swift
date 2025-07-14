//
//  AppDependencyConfiguration.swift
//  NoWeekend
//
//  Created by 이지훈 on 7/3/25.
//

import CalendarFeature
import DataBridge
import DIContainer
import Foundation
import HomeFeature
import LoginFeature
import NWNetwork
import OnboardingFeature
import ProfileFeature

enum AppDependencyConfiguration {
    static func configure() {
        print("🔧 DI Container 앱 설정 시작")
        
        registerTokenStorage()
        registerNetworkServices()
        
        DataBridge.initialize()
        
        HomeFeatureModule.registerUseCases()
        ProfileFeatureModule.registerUseCases()
        CalendarFeatureModule.registerUseCases()
        OnboardingFeatureModule.registerUseCases()
        LoginFeatureModule.registerUseCases()
        
        print("✅ DI Container 설정 완료")
    }
    
    private static func registerTokenStorage() {
        DIContainer.shared.register(TokenManagerInterface.self) { _ in
            TokenManager()
        }
    }
    
    private static func registerNetworkServices() {
        DIContainer.shared.register(NWNetworkServiceProtocol.self) { _ in
            let tokenManager = DIContainer.shared.resolve(TokenManagerInterface.self)
            let savedToken = tokenManager.getAccessToken()
            let authToken = savedToken?.isEmpty == false ? savedToken : Config.tempAccessToken
            
            return NWNetworkService(authToken: authToken)
        }
    }
}
