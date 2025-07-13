//
//  AppState.swift
//  NoWeekend
//
//  Created by 이지훈 on 7/3/25.
//

import Combine
import DIContainer
import Foundation
import LoginFeature
import NWNetwork
import OnboardingDomain

@MainActor
@Observable
public class AppState {
    public var isLoggedIn: Bool = false
    public var isOnboardingCompleted: Bool = false
    public var isLoading: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    private let tokenManager: TokenManagerInterface
    
    public init() {
        self.tokenManager = DIContainer.shared.resolve(TokenManagerInterface.self)
        setupLoginBinding()
    }
    
    private func setupLoginBinding() {
        let loginStore: LoginStore = DIContainer.shared.resolve(LoginStore.self)
        
        loginStore.effect
            .receive(on: DispatchQueue.main)
            .sink { [weak self] effect in
                switch effect {
                case .navigateToHome:
                    self?.handleLoginSuccess()
                case .navigateToOnboarding:
                    self?.handleLoginSuccess()
                case .navigateToLogin:
                    self?.handleLogout()
                case .showError(let message):
                    print("로그인 에러: \(message)")
                case .showWithdrawalSuccess:
                    print("회원탈퇴 성공")
                @unknown default:
                    print("알 수 없는 Effect: \(effect)")
                }
            }
            .store(in: &cancellables)
    }
    
    public func checkLoginStatus() {
        isLoading = true
        
        DispatchQueue.main.async {
            let hasValidToken = self.tokenManager.hasValidAccessToken()
            self.isLoggedIn = hasValidToken
            
            if hasValidToken {
                self.checkOnboardingStatus()
            } else {
                self.isLoading = false
            }
        }
    }
    
    public func checkOnboardingStatus() {
        let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboarding_completed")
        self.isOnboardingCompleted = onboardingCompleted
        
        isLoading = false
    }
    
    public func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboarding_completed")
        isOnboardingCompleted = true
    }
    
    private func handleLoginSuccess() {
        isLoggedIn = true
        checkOnboardingStatus()
    }
    
    private func handleLogout() {
        isLoggedIn = false
        isOnboardingCompleted = false
    }
    
    public func logout() {
        tokenManager.clearAllTokens()
        UserDefaults.standard.removeObject(forKey: "onboarding_completed")
        
        isLoggedIn = false
        isOnboardingCompleted = false
        
        updateNetworkServiceToken(nil)
        
        print("✅ 수동 로그아웃 완료")
    }
    
    public func getAuthenticationState() -> (isLoggedIn: Bool, isOnboardingCompleted: Bool) {
        let hasValidToken = tokenManager.hasValidAccessToken()
        let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboarding_completed")
        
        return (isLoggedIn: hasValidToken, isOnboardingCompleted: onboardingCompleted)
    }
    
    private func updateNetworkServiceToken(_ token: String?) {
        DIContainer.shared.register(NWNetworkServiceProtocol.self) { _ in
            return NWNetworkService(authToken: token)
        }
        
        print("🔄 NetworkService 토큰 업데이트: \(token != nil ? "있음" : "없음")")
    }
}
