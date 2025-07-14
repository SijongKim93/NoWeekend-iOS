//
//  AppleAuthServiceInterface.swift
//  Domain
//
//  Created by SiJongKim on 6/30/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import UIKit

public protocol AppleAuthServiceInterface {
    @MainActor
    func signIn() async throws -> AppleSignInResult

    func getCredentialState(for userID: String) async throws -> String
    
    @MainActor
    func requestWithdrawalAuthorization() async throws -> String
    
    func signOut()
}
