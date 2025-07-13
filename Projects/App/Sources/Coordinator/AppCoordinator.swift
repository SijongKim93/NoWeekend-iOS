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
    
    private var cancellables = Set<AnyCancellable>()
    private let tokenManager: TokenManagerInterface
    
    public init() {
        self.tokenManager = DIContainer.shared.resolve(TokenManagerInterface.self)
        setupBindings()
        checkInitialFlow()
    }
    
    // MARK: - Coordinatorable Implementation
    
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
    
    // MARK: - Navigation Methods
    
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
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        let loginStore: LoginStore = DIContainer.shared.resolve(LoginStore.self)
        
        loginStore.effect
            .receive(on: DispatchQueue.main)
            .sink { [weak self] effect in
                switch effect {
                case .navigateToHome:
                    self?.navigateToMain()
                case .navigateToOnboarding:
                    self?.navigateToOnboarding()
                case .navigateToLogin:
                    self?.navigateToLogin()
                case .showError, .showWithdrawalSuccess:
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkInitialFlow() {
        let hasValidToken = tokenManager.hasValidAccessToken()
        
        if hasValidToken {
            let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboarding_completed")
            if onboardingCompleted {
                currentScreen = .main
            } else {
                currentScreen = .onboarding
            }
        } else {
            currentScreen = .login
        }
    }
}
