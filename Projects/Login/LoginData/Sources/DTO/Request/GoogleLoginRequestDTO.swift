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
}
