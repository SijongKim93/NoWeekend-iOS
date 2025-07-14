//
//  AppCoordinator.swift
//  App
//
//  Created by 김시종 on 7/13/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Combine
import Coordinator
import DIContainer
import SwiftUI
import LoginFeature
import NWNetwork
import OnboardingFeature

@MainActor
public final class AppCoordinator: ObservableObject, Coordinatorable {
    public typealias Screen = AppRouter.Screen
    public typealias SheetScreen = AppRouter.Sheet
    public typealias FullScreen = AppRouter.FullScreen
    
    public typealias PushView = AnyView
    public typealias SheetView = AnyView
    public typealias FullView = AnyView
    
    @Published public var path: NavigationPath = NavigationPath()
    @Published public var sheet: SheetScreen?
    @Published public var fullScreenCover: FullScreen?

    @Published public var currentScreen: Screen = .login
    @Published public var isLoading: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    private let tokenManager: TokenManagerInterface
    
    public init() {
        self.tokenManager = DIContainer.shared.resolve(TokenManagerInterface.self)
        
        setupLoginEffectBinding()
        checkInitialFlow()
        
    }
    
    // MARK: - 📱 Coordinatorable Implementation
    
    public func view(_ screen: Screen) -> AnyView {
        switch screen {
        case .login:
            return AnyView(LoginView())
        case .onboarding:
            return AnyView(
                OnboardingView()
                    .onReceive(NotificationCenter.default.publisher(for: .init("OnboardingCompleted"))) { _ in
                        self.completeOnboarding()
                    }
            )
        case .main:
            return AnyView(TabBarView())
        }
    }
    
    public func presentView(_ sheet: SheetScreen) -> AnyView {
        switch sheet {
        case .none:
            return AnyView(EmptyView())
        }
    }
    
    public func fullCoverView(_ cover: FullScreen) -> AnyView {
        switch cover {
        case .none:
            return AnyView(EmptyView())
        }
    }
    
    // MARK: - 🔗 LoginStore Effect 바인딩 (핵심 수정사항)
    
    private func setupLoginEffectBinding() {
        
        let loginStore: LoginStore = DIContainer.shared.resolve(LoginStore.self)
        
        loginStore.effect
            .receive(on: DispatchQueue.main)
            .sink { [weak self] effect in
                guard let self = self else {
                    print("❌ AppCoordinator - self가 nil (메모리 해제됨)")
                    return
                }
                
                switch effect {
                case .navigateToHome:
                    self.handleLoginSuccess(shouldGoToMain: true)
                    
                case .navigateToOnboarding:
                    self.handleLoginSuccess(shouldGoToMain: false)
                    
                case .navigateToLogin:
                    self.handleLogout()
                    
                case .showError(let message):
                    self.isLoading = false
                    
                case .showWithdrawalSuccess:
                    self.isLoading = false
                    
                @unknown default:
                    print("⚠️ AppCoordinator - 알 수 없는 Effect: \(effect)")
                }
            }
            .store(in: &cancellables)
    }
    
    
    private func handleLoginSuccess(shouldGoToMain: Bool) {
        
        let hasValidToken = tokenManager.hasValidAccessToken()
        
        if hasValidToken {
            let targetScreen: AppRouter.Screen
            
            if shouldGoToMain {
                targetScreen = .main
            } else {
                targetScreen = .onboarding
            }
            
            currentScreen = targetScreen
            
        } else {
            currentScreen = .login
        }
        
        isLoading = false
        popToRoot()
    }
    
    private func handleLogout() {
        
        UserDefaults.standard.removeObject(forKey: "onboarding_completed")
        
        currentScreen = .login
        isLoading = false
        popToRoot()
        
        print("   - 로그인 화면으로 이동 완료")
    }
    
    public func navigateToLogin() {
        currentScreen = .login
        popToRoot()
    }
    
    public func navigateToOnboarding() {
        currentScreen = .onboarding
        popToRoot()
    }
    
    public func navigateToMain() {
        currentScreen = .main
        popToRoot()
    }
    
    public func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboarding_completed")
        navigateToMain()
    }
    
    private func checkInitialFlow() {
        isLoading = true
        
        let hasValidToken = tokenManager.hasValidAccessToken()
        print("   - 유효한 토큰: \(hasValidToken)")
        
        if hasValidToken {
            let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboarding_completed")
            print("   - 온보딩 완료: \(onboardingCompleted)")
            
            if onboardingCompleted {
                print("   - 결정: 메인 화면으로 이동")
                currentScreen = .main
            } else {
                print("   - 결정: 온보딩 화면으로 이동")
                currentScreen = .onboarding
            }
        } else {
            print("   - 결정: 로그인 화면으로 이동")
            currentScreen = .login
        }
        
        isLoading = false
    }
    
    
    public func refreshAuthenticationState() {
        checkInitialFlow()
    }
}
