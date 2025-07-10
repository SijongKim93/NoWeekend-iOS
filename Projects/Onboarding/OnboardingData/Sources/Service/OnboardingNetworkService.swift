//
//  OnboardingNetworkService.swift
//  OnboardingData
//
//  Created by SiJongKim on 7/8/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import OnboardingDomain
import NWNetwork

public class OnboardingNetworkService: OnboardingNetworkServiceInterface {
    private let networkService: NWNetworkServiceProtocol
    
    public init(networkService: NWNetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    // MARK: - Profile 저장 (Domain Model → DTO 변환)
    
    public func saveProfile(_ profile: OnboardingProfile) async throws {
        // Domain Model → DTO 변환
        let dto = ProfileRequestDTO(
            nickname: profile.nickname,
            birthDate: profile.birthDate
        )
        
        let endpoint = OnboardingEndpoint.profile
        
        print("🌐 API Request: \(endpoint.method) \(endpoint.path)")
        print("📤 Profile DTO: \(dto.toDictionary)")
        
        let response: OnboardingResponseDTO = try await networkService.post(
            endpoint: endpoint.path,
            parameters: dto.toDictionary
        )
        
        guard response.success else {
            throw OnboardingError.profileSaveFailed(response.message ?? "프로필 저장 실패")
        }
        
        print("✅ Profile API call successful")
    }
    
    // MARK: - Leave 저장 (Domain Model → DTO 변환)
    
    public func saveLeave(_ leave: OnboardingLeave) async throws {
        let dto = LeaveRequestDTO(
            days: leave.days,
            hours: leave.hours
        )
        
        let endpoint = OnboardingEndpoint.leave
        
        print("🌐 API Request: \(endpoint.method) \(endpoint.path)")
        print("📤 Leave DTO: \(dto.toDictionary)")
        
        let response: OnboardingResponseDTO = try await networkService.post(
            endpoint: endpoint.path,
            parameters: dto.toDictionary
        )
        
        guard response.success else {
            throw OnboardingError.leaveSaveFailed(response.message ?? "연차 정보 저장 실패")
        }
        
        print("✅ Leave API call successful")
    }
    
    // MARK: - Tags 저장 (Domain Model → DTO 변환)
    
    public func saveTags(_ tags: OnboardingTags) async throws {
        let dto = TagRequestDTO(
            scheduleTags: tags.scheduleTags
        )
        
        let endpoint = OnboardingEndpoint.tag
        
        print("🌐 API Request: \(endpoint.method) \(endpoint.path)")
        print("📤 Tags DTO: \(dto.toDictionary)")
        
        let response: OnboardingResponseDTO = try await networkService.post(
            endpoint: endpoint.path,
            parameters: dto.toDictionary
        )
        
        guard response.success else {
            throw OnboardingError.tagsSaveFailed(response.message ?? "태그 저장 실패")
        }
        
        print("✅ Tags API call successful")
    }
}
