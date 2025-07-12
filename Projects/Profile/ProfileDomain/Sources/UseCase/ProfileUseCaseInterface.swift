//
//  UserUseCaseProtocol.swift
//  ProfileDomain
//
//  Created by 이지훈 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public protocol GetUserProfileUseCaseProtocol {
    func execute() async throws -> UserProfile
}

public protocol UpdateUserProfileUseCaseProtocol {
    func execute(_ request: UserProfileUpdateRequest) async throws -> UserProfile
}

public protocol GetUserTagsUseCaseProtocol {
    func execute() async throws -> UserTagsResponse
}

public protocol UpdateUserTagsUseCaseProtocol {
    func execute(_ request: UserTagsUpdateRequest) async throws -> UserTagsResponse
}

public protocol UpdateVacationLeaveUseCaseProtocol {
    func execute(_ leave: VacationLeave) async throws -> VacationLeave
}
