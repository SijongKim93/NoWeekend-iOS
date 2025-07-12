//
//  AppDependencyConfiguration.swift
//  NoWeekend
//
//  Created by 이지훈 on 7/3/25.
//

import Foundation
import HomeFeature
import ProfileFeature
import CalendarFeature
import OnboardingFeature
import DataBridge
import NWNetwork
import DIContainer
import LoginFeature

enum AppDependencyConfiguration {
    static func configure() {
        print("🔧 DI Container 앱 설정 시작")
        
        registerNetworkServices()
        
        DataBridge.initialize()
        
        HomeFeatureModule.registerUseCases()
        ProfileFeatureModule.registerUseCases()
        CalendarFeatureModule.registerUseCases()
        OnboardingFeatureModule.registerUseCases()
        LoginFeatureModule.registerUseCases()
        
        print("✅ DI Container 설정 완료")
    }
    
    private static func registerNetworkServices() {
        print("🌐 Network Service 등록")
        
        DIContainer.shared.register(NWNetworkServiceProtocol.self) { _ in
            let savedToken = UserDefaults.standard.string(forKey: "access_token")
            let authToken = savedToken?.isEmpty == false ? savedToken : nil
            
            print("🔑 사용할 토큰: \(authToken?.isEmpty == false ? "Bearer \(String(authToken!.prefix(20)))..." : "없음")")
            
            return NWNetworkService(authToken: authToken)
        }
        
        print("✅ Network Service 등록 완료")
    }
}
