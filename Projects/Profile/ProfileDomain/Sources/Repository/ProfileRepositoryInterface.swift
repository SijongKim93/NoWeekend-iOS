//
//  UserRepositoryProtocol.swift
//  ProfileDomain
//
//  Created by 이지훈 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public protocol ProfileRepositoryInterface {
    func getUserProfile() async throws -> UserProfile
    func updateUserProfile(_ request: UserProfileUpdateRequest) async throws -> UserProfile
    func getUserTags() async throws -> UserTagsResponse
    func updateUserTags(_ request: UserTagsUpdateRequest) async throws -> UserTagsResponse
    func updateVacationLeave(_ leave: VacationLeave) async throws -> VacationLeave
}
