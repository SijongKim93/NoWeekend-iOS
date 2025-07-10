//
//  OnboardingRepository.swift
//  OnboardingData
//
//  Created by SiJongKim on 7/8/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import OnboardingDomain

public class OnboardingRepository: OnboardingRepositoryInterface {
    
    private let service: OnboardingNetworkServiceInterface
    
    public init(service: OnboardingNetworkServiceInterface) {
        self.service = service
    }
    
    // MARK: - 온보딩 데이터 저장
    public func saveProfile(_ profile: OnboardingProfile) async throws {
        guard !profile.nickname.isEmpty else {
            throw OnboardingError.nicknameEmpty
        }
        
        guard !profile.birthDate.isEmpty else {
            throw OnboardingError.birthDateEmpty
        }
        
        try await service.saveProfile(profile)
        
        print("📝 Repository: Profile saved - \(profile.nickname)")
    }
    
    public func saveLeave(_ leave: OnboardingLeave) async throws {
        guard leave.days >= 0 else {
            throw OnboardingError.totalDaysMustBePositive
        }
        
        guard leave.hours >= 0 && leave.hours < 8 else {
            throw OnboardingError.hoursExceedLimit
        }
        
        try await service.saveLeave(leave)
        
        print("📝 Repository: Leave saved - \(leave.days)일 \(leave.hours)시간")
    }
    
    public func saveTags(_ tags: OnboardingTags) async throws {
        guard tags.scheduleTags.count >= 3 else {
            throw OnboardingError.tagsInsufficientCount
        }
        
        try await service.saveTags(tags)
        
        print("📝 Repository: Tags saved - \(tags.scheduleTags.joined(separator: ", "))")
    }
}
