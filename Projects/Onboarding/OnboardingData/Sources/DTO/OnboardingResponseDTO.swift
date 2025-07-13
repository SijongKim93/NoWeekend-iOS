//
//  OnboardingResponseDTO.swift
//  Network
//
//  Created by SiJongKim on 7/2/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public struct OnboardingResponseDTO: Decodable {
    public let result: String
    public let data: String
    public let error: ErrorInfo?
    
    public init(result: String, data: String, error: ErrorInfo? = nil) {
        self.result = result
        self.data = data
        self.error = error
    }
    
    public var isSuccess: Bool {
        return result == "SUCCESS"
    }
}

public struct ErrorInfo: Decodable {
    public let code: String?
    public let message: String?
    
    public init(code: String? = nil, message: String? = nil) {
        self.code = code
        self.message = message
    }
}
