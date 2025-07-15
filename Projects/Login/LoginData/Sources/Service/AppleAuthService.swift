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
            
            request.requestedScopes = [.fullName, .email]
            
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
        
        let identityToken = appleIDCredential.identityToken.flatMap {
            String(data: $0, encoding: .utf8)
        }
        
        let authorizationCode = appleIDCredential.authorizationCode.flatMap {
            String(data: $0, encoding: .utf8)
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
            currentContinuation?.resume(throwing: LoginError.invalidAppleCredential)
            currentContinuation = nil
            return
        }
        
        let result = AppleSignInResult(
            userIdentifier: appleIDCredential.user,
            fullName: appleIDCredential.fullName,
            email: appleIDCredential.email,
            identityToken: identityToken,
            authorizationCode: authorizationCode
        )
        
        currentContinuation?.resume(returning: result)
        currentContinuation = nil
    }
    
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
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
            currentContinuation?.resume(throwing: error)
            withdrawalContinuation?.resume(throwing: error)
        }
        
        currentContinuation = nil
        withdrawalContinuation = nil
    }
}
