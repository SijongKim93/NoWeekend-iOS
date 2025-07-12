//
//  AppleLoginRequestDTO.swift
//  Repository
//
//  Created by SiJongKim on 6/30/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public struct AppleLoginRequestDTO: Encodable {
    public let authorizationCode: String
    public let name: String?
    
    public init(authorizationCode: String, name: String?) {
        self.authorizationCode = authorizationCode
        self.name = name
        
        print("📦 AppleLoginRequestDTO 생성:")
        print("   - authorizationCode 길이: \(authorizationCode.count)자")
        print("   - name: \(name ?? "nil")")
    }
    
    enum CodingKeys: String, CodingKey {
        case authorizationCode
        case name
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        print("🔧 AppleLoginRequestDTO 인코딩 시작:")
        
        try container.encode(authorizationCode, forKey: .authorizationCode)
        print("   ✅ authorizationCode 인코딩 완료")
        
        // Apple도 name 필드를 항상 전송
        if let name = name {
            try container.encode(name, forKey: .name)
            print("   ✅ name 인코딩 완료: \(name)")
        } else {
            try container.encodeNil(forKey: .name)
            print("   ✅ name 인코딩 완료: null")
        }
        
        print("🔧 AppleLoginRequestDTO 인코딩 완료")
    }
}
