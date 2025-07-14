//
//  GoogleLoginUseCase.swift
//  LoginDomain
//
//  Created by SiJongKim on 6/11/25.
//

import Foundation
import UIKit
import Utils

public final class GoogleLoginUseCase: GoogleLoginUseCaseInterface {
    private let authRepository: AuthRepositoryInterface
    private let googleAuthService: GoogleAuthServiceInterface
    private let viewControllerProvider: ViewControllerProviderInterface
    
    public nonisolated init(
        authRepository: AuthRepositoryInterface,
        googleAuthService: GoogleAuthServiceInterface,
        viewControllerProvider: ViewControllerProviderInterface
    ) {
        self.authRepository = authRepository
        self.googleAuthService = googleAuthService
        self.viewControllerProvider = viewControllerProvider
    }
    
    @MainActor
    public func execute() async throws -> LoginUser {
        
        guard let presentingViewController = viewControllerProvider.getCurrentPresentingViewController() else {
            throw LoginError.noPresentingViewController
        }
        
        do {
            let signInResult = try await googleAuthService.signIn(
                presentingViewController: presentingViewController
            )
            
            // Authorization Code 검증
            guard !signInResult.authorizationCode.isEmpty else {
                let error = LoginError.authenticationFailed(
                    NSError(domain: "GoogleSignIn", code: -1,
                           userInfo: [NSLocalizedDescriptionKey: "Google 인증 코드를 받을 수 없습니다."])
                )
                print("🚨 UseCase에서 에러 발생, throw 시작")
                throw error
            }
            
            // 이름 정보 검증
            guard let profileName = signInResult.name, !profileName.isEmpty else {
                let error = LoginError.nameNotAvailable
                
                throw error
            }
            
            let user = try await authRepository.loginWithGoogle(
                authorizationCode: signInResult.authorizationCode,
                name: profileName
            )
            
            return user
            
        } catch {
            if let loginError = error as? LoginError {
                print("🔍 LoginError 세부 분석:")
                switch loginError {
                case .registrationRequired(let underlyingError):
                    print("📝 예상치 못한 회원가입 요구 (이미 이름을 보냈는데 발생)")
                    print("   - Underlying Error: \(underlyingError)")
                    
                case .authenticationFailed(let underlyingError):
                    print("   - 인증 실패: \(underlyingError)")
                    
                case .nameNotAvailable:
                    print("   - 이름 정보 없음")
                    print("   - Google 계정에서 이름 정보를 확인해주세요.")
                    
                case .noPresentingViewController:
                    print("   - PresentingViewController 없음")
                    
                case .appleSignInCancelled, .appleSignInFailed, .invalidAppleCredential:
                    print("   - Apple 관련 오류 (Google 로그인에서 발생)")
                    
                case .withdrawalFailed, .withdrawalCancelled:
                    print("   - 탈퇴 관련 오류 (Google 로그인에서 발생)")
                }
        
                throw loginError
                
            } else {
                let wrappedError = LoginError.authenticationFailed(error)
                throw wrappedError
            }
        }
    }
}
