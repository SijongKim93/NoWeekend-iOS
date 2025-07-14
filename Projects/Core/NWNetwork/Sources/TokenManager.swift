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
    
    public init() {}
    
    // MARK: - Access Token 관리
    public func saveAccessToken(_ token: String) {
        userDefaults.set(token, forKey: TokenKey.accessToken)
        userDefaults.synchronize()
        print("✅ Access Token 저장 완료")
    }
    
    public func getAccessToken() -> String? {
        let token = userDefaults.string(forKey: TokenKey.accessToken)
        
        return token
    }
    
    // MARK: - 토큰 관리
    public func clearAllTokens() {
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
