//
//  AppleAuthService.swift
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
            request.requestedScopes = [.fullName, .email]
            
            print("   - Provider: \(type(of: appleIDProvider))")
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            
            authorizationController.performRequests()
        }
    }
    
    @MainActor
    public func requestWithdrawalAuthorization() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            self.withdrawalContinuation = continuation
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            
            authorizationController.performRequests()
        }
    }
    
    public func getCredentialState(for userID: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
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
        print("   - Provider: \(authorization.provider)")
        print("   - Credential Type: \(type(of: authorization.credential))")
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            let error = LoginError.invalidAppleCredential
            currentContinuation?.resume(throwing: error)
            withdrawalContinuation?.resume(throwing: error)
            currentContinuation = nil
            withdrawalContinuation = nil
            return
        }
        
        print("   - User Identifier: \(appleIDCredential.user)")
        print("   - Email: \(appleIDCredential.email ?? "없음")")
        
        // 🔍 토큰 정보 상세 분석
        print("🔍 토큰 정보 분석:")
        
        // Identity Token 확인
        let identityToken = appleIDCredential.identityToken.flatMap {
            String(data: $0, encoding: .utf8)
        }
        
        // Authorization Code 확인
        let authorizationCode = appleIDCredential.authorizationCode.flatMap {
            String(data: $0, encoding: .utf8)
        }
        
        if let identityToken = identityToken {
            print("🔐 Identity Token 전체 내용:")
            print("   - 전체 토큰:")
            print("     \(identityToken)")
        } else {
            print("   - Identity Token: 없음")
        }
        
        if let authorizationCode = authorizationCode {
            print("🎫 Authorization Code 전체 내용:")
            print("   - 전체 코드:")
            print("     \(authorizationCode)")
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
            print("   \(identityToken)")
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
        
        print("🔍 서버 전송용 토큰 선택:")
        
        guard let authorizationCode = authorizationCode else {
            print("❌ Authorization Code가 없어서 로그인 불가")
            currentContinuation?.resume(throwing: LoginError.invalidAppleCredential)
            currentContinuation = nil
            return
        }
        
        print("✅ 서버에 전달할 Authorization Code 전체:")
        print("   - 전체 코드: \(authorizationCode)")
        
        // AppleSignInResult 생성
        let result = AppleSignInResult(
            userIdentifier: appleIDCredential.user,
            fullName: appleIDCredential.fullName,
            email: appleIDCredential.email,
            identityToken: identityToken,
            authorizationCode: authorizationCode
        )
        
        print("✅ Apple 로그인 완료 - UseCase로 전달")
        print("   - Identity Token 전체: \(result.identityToken ?? "없음")")
        print("   - Authorization Code 전체: \(result.authorizationCode ?? "없음")")
        
        currentContinuation?.resume(returning: result)
        currentContinuation = nil
    }
    
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        print("   - Error: \(error)")
        
        if let authError = error as? ASAuthorizationError {
            let loginError: LoginError
            switch authError.code {
            case .canceled:
                loginError = LoginError.appleSignInCancelled
            case .failed:
                loginError = LoginError.appleSignInFailed
            case .invalidResponse:
                loginError = LoginError.invalidAppleCredential
            case .notHandled:
                loginError = LoginError.appleSignInFailed
            case .unknown:
                loginError = LoginError.appleSignInFailed
            @unknown default:
                loginError = LoginError.appleSignInFailed
            }
            
            currentContinuation?.resume(throwing: loginError)
            withdrawalContinuation?.resume(throwing: loginError)
        } else {
            print("   - \(error.localizedDescription)")
            currentContinuation?.resume(throwing: error)
            withdrawalContinuation?.resume(throwing: error)
        }
        
        currentContinuation = nil
        withdrawalContinuation = nil
    }
}
