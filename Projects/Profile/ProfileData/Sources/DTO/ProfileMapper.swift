//
//  ProfileMapper.swift
//  ProfileData
//
//  Created by SiJongKim on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import ProfileDomain

extension UserProfileDTO {
    public func toDomain() -> UserProfile {
        UserProfile(
            id: id,
            email: email,
            name: name,
            nickname: nil,
            gender: Gender(rawValue: gender) ?? .other,
            providerId: providerId,
            providerType: ProviderType(rawValue: providerType) ?? .apple,
            revocableToken: revocableToken ?? "",
            role: UserRole(rawValue: role) ?? .user,
            birthDate: birthDate,
            remainingAnnualLeave: remainingAnnualLeave,
            createdAt: createdAt,
            updatedAt: updatedAt,
            location: location?.toDomain(),
            averageTemperature: averageTemperature
        )
    }
}

extension UserLocationDTO {
    public func toDomain() -> UserLocation {
        UserLocation(latitude: latitude, longitude: longitude)
    }
}

extension UserTagDTO {
    public func toDomain() -> UserTag {
        UserTag(
            id: id,
            content: content,
            userId: userId,
            selected: selected
        )
    }
}

extension UserTagsResponseDTO {
    public func toDomain() -> UserTagsResponse {
        UserTagsResponse(
            selectedBasicTags: selectedBasicTags.map { $0.toDomain() },
            unselectedBasicTags: unselectedBasicTags.map { $0.toDomain() },
            selectedCustomTags: selectedCustomTags.map { $0.toDomain() },
            unselectedCustomTags: unselectedCustomTags.map { $0.toDomain() }
        )
    }
}

extension VacationLeaveDTO {
    public func toDomain() -> VacationLeave {
        VacationLeave(days: days, hours: hours)
    }
}

extension UserProfileUpdateRequest {
    public func toDTO() -> UserProfileUpdateRequestDTO {
        UserProfileUpdateRequestDTO(
            nickname: nickname,
            birthDate: birthDate
        )
    }
}

extension UserTagsUpdateRequest {
    public func toDTO() -> UserTagsUpdateRequestDTO {
        UserTagsUpdateRequestDTO(
            addScheduleTags: addScheduleTags,
            deleteScheduleTags: deleteScheduleTags
        )
    }
}

extension VacationLeave {
    public func toDTO() -> VacationLeaveDTO {
        VacationLeaveDTO(days: days, hours: hours)
    }
}
