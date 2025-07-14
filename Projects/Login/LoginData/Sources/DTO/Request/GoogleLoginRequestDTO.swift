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
    }
    
    enum CodingKeys: String, CodingKey {
        case authorizationCode
        case name
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(authorizationCode, forKey: .authorizationCode)
        print("   ✅ authorizationCode 인코딩 완료")
        
        if let name = name {
            try container.encode(name, forKey: .name)
        } else {
            try container.encodeNil(forKey: .name)
        }
    }
}
