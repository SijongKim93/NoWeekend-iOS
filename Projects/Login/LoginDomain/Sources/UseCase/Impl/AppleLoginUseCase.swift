//
//  AppleLoginUseCase.swift
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
            
            // 2️⃣ 이름 정보 처리
            print("2️⃣ 이름 정보 처리")
            let displayName = appleResult.fullName?.formatted() ?? nil
            print("   - 서버로 전송할 이름: \(displayName ?? "nil")")
            
            // 3️⃣ 인증 코드 준비
            print("3️⃣ 인증 코드 준비")
            print("   - Identity Token: \(appleResult.identityToken != nil ? "있음" : "없음")")
            print("   - Authorization Code: \(appleResult.authorizationCode != nil ? "있음" : "없음")")
            
            // ⚠️ 서버에 전달할 토큰 검증
            guard let authorizationCode = appleResult.authorizationCode else {
                throw LoginError.invalidAppleCredential
            }
            
            print("📤 Repository로 전달할 데이터:")
            print("   - Authorization Code 길이: \(authorizationCode.count)자")
            print("   - Authorization Code 앞 30자: \(String(authorizationCode.prefix(30)))...")
            print("   - Authorization Code 형태: \(authorizationCode.hasPrefix("eyJ") ? "❌ JWT (잘못됨)" : "✅ 정상")")
            
            let loginUser = try await authRepository.loginWithApple(
                authorizationCode: authorizationCode,
                name: displayName
            )
            
            print("✅ Apple 로그인 UseCase 완료")
            return loginUser
            
        } catch {
            print("❌ Apple 로그인 UseCase 실패:")
            print("   - Error: \(error)")
            throw error
        }
    }
}
