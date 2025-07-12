//
//  GoogleLoginRequestDTO.swift
//  Repository
//
//  Created by SiJongKim on 6/30/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public struct GoogleLoginRequestDTO: Encodable {
    public let authorizationCode: String
    public let name: String?
    
    public init(authorizationCode: String, name: String?) {
        self.authorizationCode = authorizationCode
        self.name = name
        
        // 디버깅을 위한 로그
        print("📦 GoogleLoginRequestDTO 생성:")
        print("   - authorizationCode 길이: \(authorizationCode.count)자")
        print("   - name: \(name ?? "nil")")
    }
    
    enum CodingKeys: String, CodingKey {
        case authorizationCode
        case name
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        print("🔧 GoogleLoginRequestDTO 인코딩 시작:")
        
        // authorizationCode는 항상 전송
        try container.encode(authorizationCode, forKey: .authorizationCode)
        print("   ✅ authorizationCode 인코딩 완료")
        
        // name은 nil이어도 필드로 전송 (서버에서 처리하도록)
        if let name = name {
            try container.encode(name, forKey: .name)
            print("   ✅ name 인코딩 완료: \(name)")
        } else {
            // nil도 명시적으로 전송
            try container.encodeNil(forKey: .name)
            print("   ✅ name 인코딩 완료: null")
        }
        
        print("🔧 GoogleLoginRequestDTO 인코딩 완료")
    }
}
