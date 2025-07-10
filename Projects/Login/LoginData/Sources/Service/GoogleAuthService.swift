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
        print("🔐 GoogleAuthService 초기화 완료")
        ensureGoogleSignInConfiguration()
    }
    
    @MainActor
    public func signIn(presentingViewController: UIViewController) async throws -> GoogleSignInResult {
        print("🚀 Google 로그인 시작")
        print("📱 PresentingViewController: \(type(of: presentingViewController))")
        
        // Google Sign-In 설정 상태 재확인 및 필요시 재설정
        ensureGoogleSignInConfiguration()
        
        guard let configuration = GIDSignIn.sharedInstance.configuration else {
            print("❌ Google Sign-In 설정 실패")
            throw NSError(domain: "GoogleSignIn", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Google Sign-In 설정이 누락되었습니다."])
        }
        
        print("✅ Google Sign-In 설정 확인:")
        print("   - Client ID: \(configuration.clientID)")
        print("   - Server Client ID: \(configuration.serverClientID ?? "❌ 없음")")
        
        // Authorization Code를 받으려면 serverClientID가 필수
        guard let serverClientID = configuration.serverClientID, !serverClientID.isEmpty else {
            throw NSError(
                domain: "GoogleSignIn",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Authorization Code를 받으려면 Server Client ID가 필요합니다."]
            )
        }
        
        print("🔧 Authorization Code 요청 설정 완료")
        print("   - Server Client ID: \(serverClientID)")
        
        do {
            // 추가 스코프 요청
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
            print("✅ Authorization Code 획득: \(String(authorizationCode.prefix(30)))…")
            
            // 사용자 정보 로깅
            let user = result.user
            print("👤 사용자 정보:")
            print("   - User ID: \(user.userID ?? "없음")")
            if let profile = user.profile {
                print("📋 프로필 정보:")
                print("   - Name: \(profile.name)")
            }
            
            // 서버로 전달할 결과 생성
            let signInResult = GoogleSignInResult(
                authorizationCode: authorizationCode,
                name: user.profile?.name,
                email: user.profile?.email
            )
            
            print("✅ Google 로그인 완료 - UseCase로 전달")
            return signInResult
            
        } catch {
            print("❌ Google Sign-In 실패: \(error)")
            throw error
        }
    }
    
    public func signOut() {
        print("🚪 Google 로그아웃 시작")
        GIDSignIn.sharedInstance.signOut()
        print("✅ Google 로그아웃 완료")
    }
    
    // MARK: - Private Methods
    
    private func ensureGoogleSignInConfiguration() {
        print("🔧 Google Sign-In 설정 확인 및 구성")
        
        let clientID = GoogleConfig.clientID
        let serverClientID = GoogleConfig.serverClientID
        
        
        
        let config = GIDConfiguration(
            clientID: clientID,
            serverClientID: serverClientID
        )
        
        GIDSignIn.sharedInstance.configuration = config
        
    }
}
