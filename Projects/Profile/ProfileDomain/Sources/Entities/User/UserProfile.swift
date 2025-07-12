//
//  User.swift
//  ProfileDomain
//
//  Created by 이지훈 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public struct UserProfile: Equatable {
    public let id: String
    public let email: String
    public let name: String
    public let nickname: String?
    public let gender: Gender
    public let providerId: String
    public let providerType: ProviderType
    public let revocableToken: String
    public let role: UserRole
    public let birthDate: String?
    public let remainingAnnualLeave: Double
    public let createdAt: String
    public let updatedAt: String
    public let location: UserLocation?
    public let averageTemperature: Double
    
    public init(
        id: String,
        email: String,
        name: String,
        nickname: String? = nil,
        gender: Gender,
        providerId: String,
        providerType: ProviderType,
        revocableToken: String,
        role: UserRole,
        birthDate: String? = nil,
        remainingAnnualLeave: Double,
        createdAt: String,
        updatedAt: String,
        location: UserLocation? = nil,
        averageTemperature: Double
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.nickname = nickname
        self.gender = gender
        self.providerId = providerId
        self.providerType = providerType
        self.revocableToken = revocableToken
        self.role = role
        self.birthDate = birthDate
        self.remainingAnnualLeave = remainingAnnualLeave
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.location = location
        self.averageTemperature = averageTemperature
    }
}


public struct UserProfileUpdateRequest: Equatable {
    public let nickname: String
    public let birthDate: String
    
    public init(nickname: String, birthDate: String) {
        self.nickname = nickname
        self.birthDate = birthDate
    }
}


public enum Gender: String, CaseIterable, Equatable {
    case male = "MALE"
    case female = "FEMALE"
    case other = "OTHER"
}

public enum ProviderType: String, CaseIterable, Equatable {
    case google = "GOOGLE"
    case apple = "APPLE"
}

public enum UserRole: String, CaseIterable, Equatable {
    case user = "USER"
    case admin = "ADMIN"
}
