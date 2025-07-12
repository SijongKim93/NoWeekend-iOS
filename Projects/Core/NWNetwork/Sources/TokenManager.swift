//
//  TokenManager.swift
//  Core
//
//  Created by Developer on 7/11/25.
//

import Foundation

// MARK: - 토큰 관리 인터페이스 (Domain Layer)
public protocol TokenManagerInterface {
    func saveAccessToken(_ token: String)
    func getAccessToken() -> String?
    func clearAllTokens()
    func hasValidAccessToken() -> Bool
}

// MARK: - 토큰 관리 구현체 (Data Layer)
public final class TokenManager: TokenManagerInterface {
    private let userDefaults = UserDefaults.standard
    
    // 토큰 저장 키
    private enum TokenKey {
        static let accessToken = "ACCESS_TOKEN"
    }
    
    public init() {
        print("🔐 TokenManager 초기화 완료")
    }
    
    // MARK: - Access Token 관리
    
    public func saveAccessToken(_ token: String) {
        print("💾 Access Token 저장")
        print("   - Token 앞 20자: \(String(token.prefix(20)))...")
        userDefaults.set(token, forKey: TokenKey.accessToken)
        userDefaults.synchronize()
        print("✅ Access Token 저장 완료")
    }
    
    public func getAccessToken() -> String? {
        let token = userDefaults.string(forKey: TokenKey.accessToken)
        if let token = token {
            print("📖 Access Token 조회 성공")
            print("   - Token 앞 20자: \(String(token.prefix(20)))...")
        } else {
            print("❌ Access Token 없음")
        }
        return token
    }
    
    // MARK: - 토큰 관리
    
    public func clearAllTokens() {
        print("🗑️ Access Token 삭제")
        userDefaults.removeObject(forKey: TokenKey.accessToken)
        userDefaults.synchronize()
        print("✅ Access Token 삭제 완료")
    }
    
    public func hasValidAccessToken() -> Bool {
        let hasToken = getAccessToken() != nil
        print("🔍 유효한 Access Token 존재: \(hasToken)")
        return hasToken
    }
}
