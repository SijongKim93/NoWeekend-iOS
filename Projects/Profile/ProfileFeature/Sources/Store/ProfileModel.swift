//
//  ProfileModel.swift
//  ProfileFeature
//
//  Created by SiJongKim on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import ProfileDomain

public struct ProfileState: Equatable {
    public var isLoading: Bool = false
    public var userProfile: UserProfile?
    
    public var nickname: String = ""
    public var birthDate: String = ""
    
    public var nicknameError: String?
    public var birthDateError: String?
    public var generalError: String?
    
    public var isSaving: Bool = false
    public var saveSuccess: Bool = false
    
    public var isFormValid: Bool {
        !nickname.isEmpty &&
        nicknameError == nil &&
        birthDateError == nil &&
        !isSaving
    }
    
    public init() {}
}

public enum ProfileEditAction {
    case loadUserProfile
    case userProfileLoaded(UserProfile)
    case loadUserProfileFailed(Error)
    
    case updateNickname(String)
    case updateBirthDate(String)
    
    case saveProfile
    case profileSaved(UserProfile)
    case profileSaveFailed(Error)
    
    case clearErrors
    case resetState
}

public enum ProfileEditEffect {
    case showSuccessMessage(String)
    case showErrorMessage(String)
    case navigateBack
}
