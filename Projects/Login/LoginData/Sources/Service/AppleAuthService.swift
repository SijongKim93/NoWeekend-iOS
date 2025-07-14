//
//  AppleAuthService.swift (개선된 버전)
//  Repository
//
//  Created by SiJongKim on 6/30/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import AuthenticationServices
import Combine
import Foundation
import LoginDomain

public final class AppleAuthService: NSObject, ObservableObject, AppleAuthServiceInterface {
    private var currentContinuation: CheckedContinuation<AppleSignInResult, Error>?
    private var withdrawalContinuation: CheckedContinuation<String, Error>?
    
    override public init() {
        super.init()
    }
    
    @MainActor
    public func signIn() async throws -> AppleSignInResult {
        print("🚀 Apple 로그인 시작")
        
        return try await withCheckedThrowingContinuation { continuation in
            self.currentContinuation = continuation
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            
            // 🔥 개선: 더 많은 정보 요청
            request.requestedScopes = [.fullName, .email]
            
            print("   - Provider: \(type(of: appleIDProvider))")
            print("   - 요청된 스코프: fullName, email")
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            
            authorizationController.performRequests()
        }
    }
    
    @MainActor
    public func requestWithdrawalAuthorization() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.withdrawalContinuation = continuation
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            
            authorizationController.performRequests()
        }
    }
    
    public func getCredentialState(for userID: String) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userID) { credentialState, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let stateString: String
                switch credentialState {
                case .authorized:
                    stateString = "authorized"
                case .revoked:
                    stateString = "revoked"
                case .notFound:
                    stateString = "notFound"
                case .transferred:
                    stateString = "transferred"
                @unknown default:
                    stateString = "unknown"
                }
                
                continuation.resume(returning: stateString)
            }
        }
    }
    
    public func signOut() {
        print("🚪 Apple 로그아웃 - 별도 처리 없음")
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleAuthService: ASAuthorizationControllerDelegate {
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        print("📞 Apple Sign-In 성공 콜백 받음")
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            let error = LoginError.invalidAppleCredential
            currentContinuation?.resume(throwing: error)
            withdrawalContinuation?.resume(throwing: error)
            currentContinuation = nil
            withdrawalContinuation = nil
            return
        }
        
        // 🔥 개선: 이름 정보 상세 로깅
        print("🔍 Apple 인증 정보 상세 분석:")
        print("   - User Identifier: \(appleIDCredential.user)")
        print("   - Email: \(appleIDCredential.email ?? "제공되지 않음")")
        
        if let fullName = appleIDCredential.fullName {
            print("   - 이름 정보:")
            print("     * Given Name: \(fullName.givenName ?? "nil")")
            print("     * Family Name: \(fullName.familyName ?? "nil")")
            print("     * Middle Name: \(fullName.middleName ?? "nil")")
            print("     * Nickname: \(fullName.nickname ?? "nil")")
            print("     * Name Prefix: \(fullName.namePrefix ?? "nil")")
            print("     * Name Suffix: \(fullName.nameSuffix ?? "nil")")
        } else {
            print("   - 이름 정보: 제공되지 않음 (이전 로그인 사용자)")
        }
        
        // 토큰 정보 분석
        let identityToken = appleIDCredential.identityToken.flatMap {
            String(data: $0, encoding: .utf8)
        }
        
        let authorizationCode = appleIDCredential.authorizationCode.flatMap {
            String(data: $0, encoding: .utf8)
        }
        
        print("🔍 토큰 정보:")
        if let identityToken = identityToken {
            print("   - Identity Token: 있음 (길이: \(identityToken.count))")
        } else {
            print("   - Identity Token: 없음")
        }
        
        if let authorizationCode = authorizationCode {
            print("   - Authorization Code: 있음 (길이: \(authorizationCode.count))")
        } else {
            print("   - Authorization Code: 없음")
        }
        
        if let withdrawalContinuation = withdrawalContinuation {
            handleWithdrawalAuthorization(appleIDCredential, continuation: withdrawalContinuation)
            return
        }
        
        handleRegularSignIn(appleIDCredential)
    }
    
    private func handleWithdrawalAuthorization(
        _ appleIDCredential: ASAuthorizationAppleIDCredential,
        continuation: CheckedContinuation<String, Error>
    ) {
        let identityToken = appleIDCredential.identityToken.flatMap {
            String(data: $0, encoding: .utf8)
        }
        
        if let identityToken = identityToken {
            continuation.resume(returning: identityToken)
        } else {
            continuation.resume(throwing: LoginError.invalidAppleCredential)
        }
        
        withdrawalContinuation = nil
    }
    
    private func handleRegularSignIn(_ appleIDCredential: ASAuthorizationAppleIDCredential) {
        let identityToken = appleIDCredential.identityToken.flatMap {
            String(data: $0, encoding: .utf8)
        }
        
        let authorizationCode = appleIDCredential.authorizationCode.flatMap {
            String(data: $0, encoding: .utf8)
        }
        
        guard let authorizationCode = authorizationCode else {
            print("❌ Authorization Code가 없어서 로그인 불가")
            currentContinuation?.resume(throwing: LoginError.invalidAppleCredential)
            currentContinuation = nil
            return
        }
        
        // 🔥 개선: AppleSignInResult 생성 시 이름 정보 보존
        let result = AppleSignInResult(
            userIdentifier: appleIDCredential.user,
            fullName: appleIDCredential.fullName, // PersonNameComponents 그대로 전달
            email: appleIDCredential.email,
            identityToken: identityToken,
            authorizationCode: authorizationCode
        )
        
        print("✅ Apple 로그인 완료 - UseCase로 전달")
        print("   - 이름 정보 포함 여부: \(result.fullName != nil)")
        
        currentContinuation?.resume(returning: result)
        currentContinuation = nil
    }
    
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        print("❌ Apple Sign-In 실패:")
        print("   - Error: \(error)")
        
        if let authError = error as? ASAuthorizationError {
            let loginError: LoginError
            switch authError.code {
            case .canceled:
                loginError = LoginError.appleSignInCancelled
                print("   - 사용자가 로그인 취소")
            case .failed:
                loginError = LoginError.appleSignInFailed
                print("   - 로그인 실패")
            case .invalidResponse:
                loginError = LoginError.invalidAppleCredential
                print("   - 잘못된 응답")
            case .notHandled:
                loginError = LoginError.appleSignInFailed
                print("   - 처리되지 않은 요청")
            case .unknown:
                loginError = LoginError.appleSignInFailed
                print("   - 알 수 없는 오류")
            @unknown default:
                loginError = LoginError.appleSignInFailed
                print("   - 새로운 오류 타입")
            }
            
            currentContinuation?.resume(throwing: loginError)
            withdrawalContinuation?.resume(throwing: loginError)
        } else {
            currentContinuation?.resume(throwing: error)
            withdrawalContinuation?.resume(throwing: error)
        }
        
        currentContinuation = nil
        withdrawalContinuation = nil
    }
}
