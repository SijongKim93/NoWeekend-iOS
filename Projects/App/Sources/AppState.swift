//
//  AppState.swift
//  NoWeekend
//
//  Created by 이지훈 on 7/3/25.
//

import Foundation
import DIContainer
import NWNetwork

@MainActor
@Observable
public class AppState {
    private let tokenManager: TokenManagerInterface
    
    public init() {
        self.tokenManager = DIContainer.shared.resolve(TokenManagerInterface.self)
    }
    
    // MARK: - 🔧 Utility Methods
    public func getAuthenticationState() -> (isLoggedIn: Bool, isOnboardingCompleted: Bool) {
        let hasValidToken = tokenManager.hasValidAccessToken()
        let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboarding_completed")
        
        return (isLoggedIn: hasValidToken, isOnboardingCompleted: onboardingCompleted)
    }
    
    public func logout() {
        tokenManager.clearAllTokens()
        UserDefaults.standard.removeObject(forKey: "onboarding_completed")
        
        updateNetworkServiceToken(nil)
        
        print("✅ AppState - 로그아웃 완료")
    }
    
    private func updateNetworkServiceToken(_ token: String?) {
        DIContainer.shared.register(NWNetworkServiceProtocol.self) { _ in
            return NWNetworkService(authToken: token)
        }
        
        print("🔄 NetworkService 토큰 업데이트: \(token != nil ? "있음" : "없음")")
    }
}
