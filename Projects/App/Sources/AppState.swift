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
    
    public init() {
        print("🌐 AppState 초기화")
        setupTempTokenIfNeeded()
        setupLoginBinding()
    }
    
    private func setupTempTokenIfNeeded() {
        let savedToken = UserDefaults.standard.string(forKey: "access_token")
        if savedToken?.isEmpty != false {
            print("🔑 임시 토큰을 UserDefaults에 저장")
            UserDefaults.standard.set(nil, forKey: "access_token")
        }
    }
    
    private func setupLoginBinding() {
        let loginStore: LoginStore = DIContainer.shared.resolve(LoginStore.self)
        
        loginStore.effect
            .receive(on: DispatchQueue.main)
            .sink { [weak self] effect in
                switch effect {
                case .navigateToHome:
                    self?.handleLoginSuccess()
                case .showError(let message):
                    print("로그인 에러: \(message)")
                
                @unknown default:
                    print("알 수 없는 Effect: \(effect)")
                }
            }
            .store(in: &cancellables)
    }
    
    public func checkLoginStatus() {
        isLoading = true
        
        DispatchQueue.main.async {
            let hasValidToken = self.hasValidAccessToken()
            self.isLoggedIn = hasValidToken
            
            if hasValidToken {
                self.checkOnboardingStatus()
            } else {
                self.isLoading = false
            }
            
            print("✅ 로그인 상태: \(hasValidToken)")
        }
    }
    
    public func checkOnboardingStatus() {
        let repository = DIContainer.shared.resolve(OnboardingRepositoryInterface.self)
        
        isLoading = false
        
        print("✅ 온보딩 상태 확인 완료: \(isOnboardingCompleted)")
    }
    
    public func completeOnboarding() {
        print("✅ 온보딩 완료 처리")
        isOnboardingCompleted = true
    }
    
    // MARK: - Login
    
    private func handleLoginSuccess() {
        isLoggedIn = true
        checkOnboardingStatus()
    }
    
    public func logout() {
        print("🚪 로그아웃 처리")
    
        UserDefaults.standard.removeObject(forKey: "access_token")
        
        // 상태 초기화
        isLoggedIn = false
    }
    
    private func hasValidAccessToken() -> Bool {
        guard let token = UserDefaults.standard.string(forKey: "access_token"),
              !token.isEmpty else {
            return false
        }
        return true
    }
}
