//
//  LoginStore.swift (로그아웃 Effect 수정)
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
            Task { @MainActor in
                await handleSignInSuccess(user)
            }
        case .signInFailed(let error):
            Task { @MainActor in
                await handleSignInFailure(error)
            }
        case .signOut:
            Task { await handleSignOut() }
            
        // MARK: - Apple 회원탈퇴 관련
        case .withdrawAppleAccount:
            Task { await handleAppleWithdrawal() }
        case .withdrawalSucceeded:
            Task { @MainActor in
                await handleWithdrawalSuccess()
            }
        case .withdrawalFailed(let error):
            Task { @MainActor in
                await handleWithdrawalFailure(error)
            }
        }
    }
    
    // MARK: - Google 로그인 처리
    @MainActor
    private func handleGoogleSignIn() async {
        state.errorMessage = ""
        state.isLoading = true

        do {
            let user = try await loginWithGoogleUseCase.execute()
            await handleSignInSuccess(user)
        } catch {
            await handleSignInFailure(error)
        }
    }

    @MainActor
    private func handleAppleSignIn() async {
        state.errorMessage = ""
        state.isLoading = true

        do {
            let user = try await loginWithAppleUseCase.execute()
            await handleSignInSuccess(user)
        } catch {
            await handleSignInFailure(error)
        }
    }
    
    @MainActor
    private func handleSignInSuccess(_ user: LoginUser) async {
        state.isSignedIn = true
        state.userEmail = user.email
        state.isLoading = false
        
        if let accessToken = user.accessToken {
            UserDefaults.standard.set(accessToken, forKey: "access_token")
        }
        
        if user.isExistingUser {
            effect.send(.navigateToHome)
        } else {
            effect.send(.navigateToOnboarding)
        }
    }

    @MainActor
    private func handleSignInFailure(_ error: Error) async {
        state.errorMessage = error.localizedDescription
        state.isLoading = false
        
        effect.send(.showError(message: error.localizedDescription))
    }

    @MainActor
    private func handleSignOut() async {
        print("🚪 LoginStore - 로그아웃 처리 시작")
        
        authUseCase.signOutGoogle()
        authUseCase.signOutApple()
        
        UserDefaults.standard.removeObject(forKey: "access_token")
        
        state = LoginState()
        
        
        effect.send(.navigateToLogin)
    }
    
    // MARK: - Apple 회원탈퇴 관련
    
    @MainActor
    private func handleAppleWithdrawal() async {
        state.errorMessage = ""
        state.isWithdrawing = true

        do {
            try await authUseCase.withdrawAppleAccount()
            await handleWithdrawalSuccess()
        } catch {
            await handleWithdrawalFailure(error)
        }
    }
    
    @MainActor
    private func handleWithdrawalSuccess() async {
        state.isWithdrawing = false
        state = LoginState()
        
        UserDefaults.standard.removeObject(forKey: "access_token")
        
        effect.send(.showWithdrawalSuccess)
        effect.send(.navigateToLogin)
    }
    
    @MainActor
    private func handleWithdrawalFailure(_ error: Error) async {
        state.errorMessage = error.localizedDescription
        state.isWithdrawing = false
        effect.send(.showError(message: error.localizedDescription))
    }
}
