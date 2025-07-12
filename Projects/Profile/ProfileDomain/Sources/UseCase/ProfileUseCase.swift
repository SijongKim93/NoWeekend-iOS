//
//  ProfileUseCases.swift
//  ProfileDomain
//
//  Created by 김시종 on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public final class GetUserProfileUseCase: GetUserProfileUseCaseProtocol {
    
    private let repository: ProfileRepositoryInterface
    
    public init(repository: ProfileRepositoryInterface) {
        self.repository = repository
    }
    
    public func execute() async throws -> UserProfile {
        try await repository.getUserProfile()
    }
}

public final class UpdateUserProfileUseCase: UpdateUserProfileUseCaseProtocol {
    
    private let repository: ProfileRepositoryInterface
    
    public init(repository: ProfileRepositoryInterface) {
        self.repository = repository
    }
    
    public func execute(_ request: UserProfileUpdateRequest) async throws -> UserProfile {
        try validateProfileUpdate(request)
        
        return try await repository.updateUserProfile(request)
    }
    
    private func validateProfileUpdate(_ request: UserProfileUpdateRequest) throws {
        if request.nickname.isEmpty {
            throw ProfileValidationError.emptyNickname
        }
        
        if request.nickname.count > 6 {
            throw ProfileValidationError.nicknameTooLong
        }
        
        if !isValidBirthDate(request.birthDate) {
            throw ProfileValidationError.invalidBirthDate
        }
    }
    
    private func isValidBirthDate(_ birthDate: String) -> Bool {
        guard birthDate.count == 8,
              birthDate.allSatisfy({ $0.isNumber }) else {
            return false
        }
        
        let yearString = String(birthDate.prefix(4))
        let monthString = String(birthDate.dropFirst(4).prefix(2))
        let dayString = String(birthDate.suffix(2))
        
        guard let year = Int(yearString),
              let month = Int(monthString),
              let day = Int(dayString) else {
            return false
        }
        
        guard year >= 1900 && year <= 2025,
              month >= 1 && month <= 12,
              day >= 1 && day <= 31 else {
            return false
        }
        
        return true
    }
}

// MARK: - Get User Tags Use Case

public final class GetUserTagsUseCase: GetUserTagsUseCaseProtocol {
    
    private let repository: ProfileRepositoryInterface
    
    public init(repository: ProfileRepositoryInterface) {
        self.repository = repository
    }
    
    public func execute() async throws -> UserTagsResponse {
        try await repository.getUserTags()
    }
}

// MARK: - Update User Tags Use Case

public final class UpdateUserTagsUseCase: UpdateUserTagsUseCaseProtocol {
    
    private let repository: ProfileRepositoryInterface
    
    public init(repository: ProfileRepositoryInterface) {
        self.repository = repository
    }
    
    public func execute(_ request: UserTagsUpdateRequest) async throws -> UserTagsResponse {
        try validateTagsUpdate(request)
        
        return try await repository.updateUserTags(request)
    }
    
    private func validateTagsUpdate(_ request: UserTagsUpdateRequest) throws {
        for tag in request.addScheduleTags {
            if tag.isEmpty {
                throw ProfileValidationError.emptyTag
            }
            if tag.count > 20 {
                throw ProfileValidationError.tagTooLong
            }
        }
        
        let addSet = Set(request.addScheduleTags)
        let deleteSet = Set(request.deleteScheduleTags)
        
        if !addSet.isDisjoint(with: deleteSet) {
            throw ProfileValidationError.duplicateTagOperation
        }
    }
}

// MARK: - Update Vacation Leave Use Case

public final class UpdateVacationLeaveUseCase: UpdateVacationLeaveUseCaseProtocol {
    
    private let repository: ProfileRepositoryInterface
    
    public init(repository: ProfileRepositoryInterface) {
        self.repository = repository
    }
    
    public func execute(_ leave: VacationLeave) async throws -> VacationLeave {
        try validateVacationLeave(leave)
        
        return try await repository.updateVacationLeave(leave)
    }
    
    private func validateVacationLeave(_ leave: VacationLeave) throws {
        if leave.days < 0 || leave.days > 50 {
            throw ProfileValidationError.invalidVacationDays
        }
        
        if leave.hours < 0 || leave.hours > 23 {
            throw ProfileValidationError.invalidVacationHours
        }
        
        let totalHours = leave.days * 8 + leave.hours
        if totalHours > 50 * 8 + 23 {
            throw ProfileValidationError.vacationLeaveTooLong
        }
    }
}

// MARK: - Validation Errors

public enum ProfileValidationError: Error, LocalizedError {
    case emptyNickname
    case nicknameTooLong
    case invalidBirthDate
    case emptyTag
    case tagTooLong
    case duplicateTagOperation
    case invalidVacationDays
    case invalidVacationHours
    case vacationLeaveTooLong
    
    public var errorDescription: String? {
        switch self {
        case .emptyNickname:
            return "닉네임을 입력해주세요"
        case .nicknameTooLong:
            return "닉네임은 6글자 이하로 입력해주세요"
        case .invalidBirthDate:
            return "올바른 생년월일을 입력해주세요"
        case .emptyTag:
            return "태그 내용을 입력해주세요"
        case .tagTooLong:
            return "태그는 20글자 이하로 입력해주세요"
        case .duplicateTagOperation:
            return "같은 태그를 추가와 삭제에 동시에 포함할 수 없습니다"
        case .invalidVacationDays:
            return "연차 일수는 0~50일 사이여야 합니다"
        case .invalidVacationHours:
            return "연차 시간은 0~23시간 사이여야 합니다"
        case .vacationLeaveTooLong:
            return "연차가 너무 깁니다"
        }
    }
}
