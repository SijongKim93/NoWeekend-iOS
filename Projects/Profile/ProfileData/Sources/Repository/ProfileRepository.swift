//
//  ProfileRepository.swift
//  ProfileData
//
//  Created by SiJongKim on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import ProfileDomain

public final class ProfileRepository: ProfileRepositoryInterface {
    
    private let networkService: ProfileNetworkServiceInterface
    
    public init(networkService: ProfileNetworkServiceInterface) {
        self.networkService = networkService
    }
    
    public func getUserProfile() async throws -> UserProfile {
        do {
            let userProfileDTO = try await networkService.getUserProfile()
            return userProfileDTO.toDomain()
        } catch {
            throw mapNetworkErrorToRepositoryError(error)
        }
    }
    
    public func updateUserProfile(_ request: UserProfileUpdateRequest) async throws -> UserProfile {
        do {
            let requestDTO = request.toDTO()
            let userProfileDTO = try await networkService.updateUserProfile(requestDTO)
            return userProfileDTO.toDomain()
        } catch {
            throw mapNetworkErrorToRepositoryError(error)
        }
    }
    
    public func getUserTags() async throws -> UserTagsResponse {
        do {
            let userTagsDTO = try await networkService.getUserTags()
            return userTagsDTO.toDomain()
        } catch {
            throw mapNetworkErrorToRepositoryError(error)
        }
    }
    
    public func updateUserTags(_ request: UserTagsUpdateRequest) async throws -> UserTagsResponse {
        do {
            let requestDTO = request.toDTO()
            let userTagsDTO = try await networkService.updateUserTags(requestDTO)
            return userTagsDTO.toDomain()
        } catch {
            throw mapNetworkErrorToRepositoryError(error)
        }
    }
    
    public func updateVacationLeave(_ leave: VacationLeave) async throws -> VacationLeave {
        do {
            let requestDTO = leave.toDTO()
            let vacationLeaveDTO = try await networkService.updateVacationLeave(requestDTO)
            return vacationLeaveDTO.toDomain()
        } catch {
            throw mapNetworkErrorToRepositoryError(error)
        }
    }
    
    private func mapNetworkErrorToRepositoryError(_ error: Error) -> ProfileError {
        if let networkError = error as? ProfileNetworkError {
            switch networkError {
            case .noData(let endpoint):
                return .noData(source: endpoint)
            case .updateFailed(let endpoint):
                return .updateFailed(source: endpoint)
            case .invalidResponse(let endpoint):
                return .invalidResponse(source: endpoint)
            case .networkError(let endpoint, let underlyingError):
                return .networkError(source: endpoint, underlyingError: underlyingError)
            @unknown default:
                fatalError("프로필 네트워크 오류")
            }
        }
        
        return .unknownError(error)
    }
}
