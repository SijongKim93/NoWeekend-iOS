//
//  AppleLoginUseCase.swift (개선된 버전)
//  LoginDomain
//
//  Created by SiJongKim on 6/30/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public final class AppleLoginUseCase: AppleLoginUseCaseInterface {
    private let appleAuthService: AppleAuthServiceInterface
    private let authRepository: AuthRepositoryInterface
    
    public init(
        appleAuthService: AppleAuthServiceInterface,
        authRepository: AuthRepositoryInterface
    ) {
        self.appleAuthService = appleAuthService
        self.authRepository = authRepository
        print("🏗️ AppleLoginUseCase 초기화 완료")
    }
    
    public func execute() async throws -> LoginUser {
        print("🎯 === Apple 로그인 UseCase 실행 시작 ===")
        
        do {
            // 1️⃣ Apple 인증 시도
            print("1️⃣ Apple 인증 시도")
            let appleResult = try await appleAuthService.signIn()
            
            print("🔍 Apple 인증 결과 분석:")
            print("   - User Identifier: \(appleResult.userIdentifier)")
            print("   - Email: \(appleResult.email ?? "없음")")
            print("   - Identity Token 있음: \(appleResult.identityToken != nil)")
            print("   - Authorization Code 있음: \(appleResult.authorizationCode != nil)")
            
            // 🔍 이름 정보 상세 분석
            print("🔍 이름 정보 상세 분석:")
            if let fullName = appleResult.fullName {
                print("   - fullName 객체 존재: ✅")
                print("   - givenName: \(fullName.givenName ?? "nil")")
                print("   - familyName: \(fullName.familyName ?? "nil")")
                print("   - middleName: \(fullName.middleName ?? "nil")")
                print("   - nickname: \(fullName.nickname ?? "nil")")
            } else {
                print("   - fullName 객체: ❌ nil")
            }
            
            // 2️⃣ 이름 정보 처리 (개선된 로직)
            print("2️⃣ 이름 정보 처리")
            let displayName = extractDisplayName(from: appleResult)
            print("   - 추출된 이름: \(displayName ?? "nil")")
            print("   - 이름 추출 성공: \(displayName != nil ? "✅" : "❌")")
            
            // 🔍 토큰 상세 분석
            if let identityToken = appleResult.identityToken {
                print("🔍 Identity Token 분석:")
                print("   - 길이: \(identityToken.count)자")
                print("   - 앞 30자: \(String(identityToken.prefix(30)))...")
                print("   - JWT 형태: \(identityToken.hasPrefix("eyJ"))")
            }
            
            if let authCode = appleResult.authorizationCode {
                print("🔍 Authorization Code 분석:")
                print("   - 길이: \(authCode.count)자")
                print("   - 앞 30자: \(String(authCode.prefix(30)))...")
                print("   - 형태: \(authCode.hasPrefix("eyJ") ? "JWT (잘못됨!)" : "정상 Auth Code")")
            }
            
            // 3️⃣ 인증 코드 준비
            print("3️⃣ 인증 코드 준비")
            guard let authorizationCode = appleResult.authorizationCode else {
                print("❌ Authorization Code가 없음")
                throw LoginError.invalidAppleCredential
            }
            
            print("📤 Repository로 전달할 데이터:")
            print("   - Authorization Code 길이: \(authorizationCode.count)자")
            print("   - Authorization Code 앞 30자: \(String(authorizationCode.prefix(30)))...")
            print("   - 이름: \(displayName ?? "없음")")
            print("   - 이메일: \(appleResult.email ?? "없음")")
            
            // 4️⃣ 서버로 로그인 요청
            print("4️⃣ 서버로 로그인 요청")
            let loginUser = try await authRepository.loginWithApple(
                authorizationCode: authorizationCode,
                name: displayName
            )
            
            print("✅ Apple 로그인 UseCase 완료")
            return loginUser
            
        } catch {
            print("❌ Apple 로그인 UseCase 실패:")
            print("   - Error: \(error)")
            
            // 에러 타입에 따른 상세 로깅
            if let loginError = error as? LoginError {
                print("   - LoginError 타입: \(loginError)")
            }
            
            throw error
        }
    }
    
    // MARK: - 🔥 개선된 이름 추출 로직
    
    /// Apple Sign-In 결과에서 사용자 이름을 추출
    private func extractDisplayName(from result: AppleSignInResult) -> String? {
        guard let fullName = result.fullName else {
            print("   - fullName이 nil - 이전에 로그인한 사용자이거나 정보 제공 거부")
            return nil
        }
        
        // 1. 한국식 이름 조합 (성 + 이름)
        if let familyName = fullName.familyName,
           let givenName = fullName.givenName,
           !familyName.isEmpty,
           !givenName.isEmpty {
            let koreanStyleName = familyName + givenName
            print("   - 한국식 이름 조합: \(koreanStyleName)")
            return koreanStyleName
        }
        
        // 2. 서양식 이름 조합 (이름 + 성)
        if let givenName = fullName.givenName,
           let familyName = fullName.familyName,
           !givenName.isEmpty,
           !familyName.isEmpty {
            let westernStyleName = "\(givenName) \(familyName)"
            print("   - 서양식 이름 조합: \(westernStyleName)")
            return westernStyleName
        }
        
        // 3. 이름만 있는 경우
        if let givenName = fullName.givenName, !givenName.isEmpty {
            print("   - 이름만 사용: \(givenName)")
            return givenName
        }
        
        // 4. 성만 있는 경우
        if let familyName = fullName.familyName, !familyName.isEmpty {
            print("   - 성만 사용: \(familyName)")
            return familyName
        }
        
        // 5. 닉네임이 있는 경우
        if let nickname = fullName.nickname, !nickname.isEmpty {
            print("   - 닉네임 사용: \(nickname)")
            return nickname
        }
        
        // 6. 모든 정보가 비어있는 경우
        print("   - 모든 이름 정보가 비어있음")
        return nil
    }
}
