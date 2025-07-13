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
        print("🏗️ GoogleLoginUseCase 초기화 완료")
    }
    
    @MainActor
    public func execute() async throws -> LoginUser {
        print("\n🎯 === Google 로그인 UseCase 실행 시작 ===")
        
        guard let presentingViewController = viewControllerProvider.getCurrentPresentingViewController() else {
            print("❌ PresentingViewController를 찾을 수 없습니다.")
            throw LoginError.noPresentingViewController
        }
        print("✅ PresentingViewController 찾음: \(type(of: presentingViewController))")
        
        do {
            print("\n1️⃣ Google 인증 시도 (이름 포함)")
            let signInResult = try await googleAuthService.signIn(
                presentingViewController: presentingViewController
            )
            
            print("🔍 Google 인증 결과 검증:")
            print("   - Authorization Code 비어있음: \(signInResult.authorizationCode.isEmpty)")
            print("   - Name: \(signInResult.name ?? "❌ 없음")")
            print("   - Email: \(signInResult.email ?? "❌ 없음")")
            
            // Authorization Code 검증
            guard !signInResult.authorizationCode.isEmpty else {
                print("❌ Google 인증 코드가 비어있습니다.")
                throw LoginError.authenticationFailed(
                    NSError(domain: "GoogleSignIn", code: -1,
                           userInfo: [NSLocalizedDescriptionKey: "Google 인증 코드를 받을 수 없습니다."])
                )
            }
            
            // 이름 정보 검증
            guard let profileName = signInResult.name, !profileName.isEmpty else {
                print("❌ 프로필 이름을 가져올 수 없습니다.")
                print("   - Name 값: \(signInResult.name ?? "nil")")
                print("   - 이름 정보가 필요합니다. Google 계정에서 이름 정보를 확인해주세요.")
                throw LoginError.nameNotAvailable
            }
            
            // Step 2: 서버 API 호출 (이름 포함)
            print("\n2️⃣ 서버 API 호출 시도 (이름 포함)")
            print("📤 서버로 전송할 데이터:")
            print("   - Authorization Code 길이: \(signInResult.authorizationCode.count)자")
            print("   - Authorization Code 앞 20자: \(String(signInResult.authorizationCode.prefix(20)))...")
            print("   - Name: \(profileName)")
            print("   - Email: \(signInResult.email ?? "없음")")
            
            print("🌐 AuthRepository.loginWithGoogle 호출 중...")
            
            let user = try await authRepository.loginWithGoogle(
                authorizationCode: signInResult.authorizationCode,
                name: profileName // 🔥 이제 첫 번째 시도에서도 이름을 함께 전송
            )
            
            // Step 3: 서버 응답에 따른 처리
            if user.isExistingUser {
                print("✅ 기존 사용자 로그인 성공!")
                print("👤 기존 사용자 정보:")
                print("   - Email: \(user.email)")
                print("   - 기존 사용자: true")
            } else {
                print("✅ 신규 사용자 회원가입 및 로그인 성공!")
                print("👤 신규 사용자 정보:")
                print("   - Email: \(user.email)")
                print("   - 기존 사용자: false")
                print("   - 사용된 이름: \(profileName)")
            }
            
            print("🎉 === Google 로그인/회원가입 완료 ===\n")
            return user
            
        } catch {
            print("\n❌ Google 로그인 실패:")
            print("   - Error Type: \(type(of: error))")
            print("   - Error Description: \(error.localizedDescription)")
            
            // 에러 세부 분석 및 재매핑
            if let loginError = error as? LoginError {
                print("🔍 LoginError 세부 분석:")
                switch loginError {
                case .registrationRequired(let underlyingError):
                    print("📝 예상치 못한 회원가입 요구 (이미 이름을 보냈는데 발생)")
                    print("   - Underlying Error: \(underlyingError)")
                    throw loginError
                    
                case .authenticationFailed(let underlyingError):
                    print("   - 인증 실패: \(underlyingError)")
                    throw loginError
                    
                case .nameNotAvailable:
                    print("   - 이름 정보 없음")
                    print("   - Google 계정에서 이름 정보를 확인해주세요.")
                    throw loginError
                    
                case .noPresentingViewController:
                    print("   - PresentingViewController 없음")
                    throw loginError
                    
                case .appleSignInCancelled, .appleSignInFailed, .invalidAppleCredential:
                    print("   - Apple 관련 오류 (Google 로그인에서 발생)")
                    throw loginError
                    
                case .withdrawalFailed, .withdrawalCancelled:
                    print("   - 탈퇴 관련 오류 (Google 로그인에서 발생)")
                    throw loginError
                }
            } else {
                print("   - 예상치 못한 에러, LoginError로 래핑")
                throw LoginError.authenticationFailed(error)
            }
        }
    }
}
