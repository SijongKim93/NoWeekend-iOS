//
//  LoginStore.swift
//  Calendar
//
//  Created by SiJongKim on 6/12/25.
//

import Combine
import Foundation
import LoginDomain

public final class LoginStore: ObservableObject {
    @Published public private(set) var state = LoginState()
    public let effect = PassthroughSubject<LoginEffect, Never>()

    private let loginWithGoogleUseCase: GoogleLoginUseCaseInterface
    private let loginWithAppleUseCase: AppleLoginUseCaseInterface
    private let authUseCase: AuthUseCaseInterface

    public init(
        loginWithGoogleUseCase: GoogleLoginUseCaseInterface,
        loginWithAppleUseCase: AppleLoginUseCaseInterface,
        authUseCase: AuthUseCaseInterface
    ) {
        self.loginWithGoogleUseCase = loginWithGoogleUseCase
        self.loginWithAppleUseCase = loginWithAppleUseCase
        self.authUseCase = authUseCase
    }

    public func send(_ intent: LoginIntent) {
        switch intent {
        // MARK: - 로그인 관련
        case .signInWithGoogle:
            Task { await handleGoogleSignIn() }
        case .signInWithApple:
            Task { await handleAppleSignIn() }
        case .signInSucceeded(let user):
            Task { await handleSignInSuccess(user) }
        case .signInFailed(let error):
            Task { await handleSignInFailure(error) }
        case .signOut:
            Task { await handleSignOut() }
            
        // MARK: - Apple 회원탈퇴 관련
        case .withdrawAppleAccount:
            Task { await handleAppleWithdrawal() }
        case .withdrawalSucceeded:
            Task { await handleWithdrawalSuccess() }
        case .withdrawalFailed(let error):
            Task { await handleWithdrawalFailure(error) }
        }
    }
    
    @MainActor
    private func handleGoogleSignIn() async {
        state.errorMessage = ""
        state.isLoading = true

        do {
            let user = try await loginWithGoogleUseCase.execute()
            send(.signInSucceeded(user: user))
        } catch {
            send(.signInFailed(error: error))
        }
    }

    @MainActor
    private func handleAppleSignIn() async {
        state.errorMessage = ""
        state.isLoading = true

        do {
            let user = try await loginWithAppleUseCase.execute()
            send(.signInSucceeded(user: user))
        } catch {
            send(.signInFailed(error: error))
        }
    }

    @MainActor
    private func handleSignInSuccess(_ user: LoginUser) {
        state.isSignedIn = true
        state.userEmail = user.email
        state.isLoading = false
        
        //키체인 변경 예정
        UserDefaults.standard.set(user.accessToken, forKey: "access_token")
        
        if user.isExistingUser {
            effect.send(.navigateToHome)
        } else {
            effect.send(.navigateToOnboarding)
        }
    }

    @MainActor
    private func handleSignInFailure(_ error: Error) {
        state.errorMessage = error.localizedDescription
        state.isLoading = false
        effect.send(.showError(message: error.localizedDescription))
    }

    @MainActor
    private func handleSignOut() {
        authUseCase.signOutGoogle()
        authUseCase.signOutApple()
        state = LoginState()
    }
    
    // MARK: - Apple 회원탈퇴 관련 Handler들
    
    @MainActor
    private func handleAppleWithdrawal() async {
        print("🗑️ Apple 계정 회원탈퇴 시작")
        state.errorMessage = ""
        state.isWithdrawing = true

        do {
            try await authUseCase.withdrawAppleAccount()
            send(.withdrawalSucceeded)
        } catch {
            send(.withdrawalFailed(error: error))
        }
    }
    
    @MainActor
    private func handleWithdrawalSuccess() {
        print("✅ Apple 계정 회원탈퇴 성공 처리")
        state.isWithdrawing = false
        state = LoginState()
        
        UserDefaults.standard.removeObject(forKey: "access_token")
        
        effect.send(.showWithdrawalSuccess)
        effect.send(.navigateToLogin)
    }
    
    @MainActor
    private func handleWithdrawalFailure(_ error: Error) {
        print("❌ Apple 계정 회원탈퇴 실패 처리: \(error)")
        state.errorMessage = error.localizedDescription
        state.isWithdrawing = false
        effect.send(.showError(message: error.localizedDescription))
    }
}
