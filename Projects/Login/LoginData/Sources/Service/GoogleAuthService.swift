//
//  GoogleAuthService.swift
//  Network
//
//  Created by 김시종 on 6/29/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import GoogleSignIn
import LoginDomain
import NWNetwork
import UIKit

public final class GoogleAuthService: GoogleAuthServiceInterface {
    public init() {
        ensureGoogleSignInConfiguration()
    }
    
    @MainActor
    public func signIn(presentingViewController: UIViewController) async throws -> GoogleSignInResult {
        ensureGoogleSignInConfiguration()
        
        guard let configuration = GIDSignIn.sharedInstance.configuration else {
            throw NSError(domain: "GoogleSignIn", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Google Sign-In 설정이 누락되었습니다."])
        }
        
        print("   - Client ID: \(configuration.clientID)")
        print("   - Server Client ID: \(configuration.serverClientID ?? "❌ 없음")")
        
        guard let serverClientID = configuration.serverClientID, !serverClientID.isEmpty else {
            throw NSError(
                domain: "GoogleSignIn",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Authorization Code를 받으려면 Server Client ID가 필요합니다."]
            )
        }
        
        print("   - Server Client ID: \(serverClientID)")
        
        do {
            let additionalScopes = [
                "https://www.googleapis.com/auth/userinfo.email",
                "https://www.googleapis.com/auth/userinfo.profile"
            ]
            
            print("🔧 추가 스코프와 함께 로그인 요청:")
            additionalScopes.forEach { print("   - \($0)") }
            
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: presentingViewController,
                hint: nil,
                additionalScopes: additionalScopes
            )
            
            guard let authorizationCode = result.serverAuthCode,
                  authorizationCode.hasPrefix("4/") else {
                throw NSError(
                    domain: "GoogleSignIn",
                    code: -4,
                    userInfo: [NSLocalizedDescriptionKey: "Authorization Code(serverAuthCode)를 받지 못했습니다."]
                )
            }
            
            let user = result.user
            print("   - User ID: \(user.userID ?? "없음")")
            if let profile = user.profile {
                print("   - Name: \(profile.name)")
            }
            
            let signInResult = GoogleSignInResult(
                authorizationCode: authorizationCode,
                name: user.profile?.name,
                email: user.profile?.email
            )
            
            return signInResult
            
        } catch {
            throw error
        }
    }
    
    public func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    // MARK: - Private Methods
    
    private func ensureGoogleSignInConfiguration() {
        let clientID = GoogleConfig.clientID
        let serverClientID = GoogleConfig.serverClientID
        
        
        
        let config = GIDConfiguration(
            clientID: clientID,
            serverClientID: serverClientID
        )
        
        GIDSignIn.sharedInstance.configuration = config
        
    }
}
