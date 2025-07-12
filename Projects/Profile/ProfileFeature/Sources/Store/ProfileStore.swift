//
//  ProfileStore.swift
//  ProfileFeature
//
//  Created by SiJongKim on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Combine
import Foundation
import ProfileDomain

public final class ProfileStore: ObservableObject {
    
    @Published public private(set) var state = ProfileState()
    
    private let effectSubject = PassthroughSubject<ProfileEffect, Never>()
    public var effect: AnyPublisher<ProfileEffect, Never> {
        effectSubject.eraseToAnyPublisher()
    }
    
    private let getUserProfileUseCase: GetUserProfileUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    public init(getUserProfileUseCase: GetUserProfileUseCaseProtocol) {
        self.getUserProfileUseCase = getUserProfileUseCase
    }
    
    public func send(_ action: ProfileAction) {
        switch action {
        case .loadUserProfile:
            handleLoadUserProfile()
            
        case .userProfileLoaded(let profile):
            handleUserProfileLoaded(profile)
            
        case .loadUserProfileFailed(let error):
            handleLoadUserProfileFailed(error)
            
        case .clearErrors:
            handleClearErrors()
            
        case .resetState:
            handleResetState()
        }
    }
    
    private func handleLoadUserProfile() {
        state.isLoading = true
        state.generalError = nil
        
        Task { @MainActor in
            do {
                let profile = try await getUserProfileUseCase.execute()
                send(.userProfileLoaded(profile))
            } catch {
                send(.loadUserProfileFailed(error))
            }
        }
    }
    
    private func handleUserProfileLoaded(_ profile: UserProfile) {
        state.isLoading = false
        state.userProfile = profile
    }
    
    private func handleLoadUserProfileFailed(_ error: Error) {
        state.isLoading = false
        state.generalError = error.localizedDescription
        effectSubject.send(.showErrorMessage("프로필 정보를 불러오는데 실패했습니다"))
    }
    
    private func handleClearErrors() {
        state.generalError = nil
    }
    
    private func handleResetState() {
        state = ProfileState()
    }
    
    func loadInitialData() {
        send(.loadUserProfile)
    }
    
    func clearErrors() {
        send(.clearErrors)
    }
    
    func resetState() {
        send(.resetState)
    }
}
