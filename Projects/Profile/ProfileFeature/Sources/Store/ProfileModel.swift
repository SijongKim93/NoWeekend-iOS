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
    public var generalError: String?
    
    public init() {}
}

public struct ProfileEditState: Equatable {
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

public struct VacationState: Equatable {
    public var remainingDays: Int = 0
    public var hasHalfDay: Bool = false
    public var remainingDaysError: String?
    public var generalError: String?
    
    public var isSaving: Bool = false
    public var saveSuccess: Bool = false
    
    public var isFormValid: Bool {
        remainingDaysError == nil && !isSaving
    }
    
    public var totalRemainingHours: Double {
        Double(remainingDays) * 8.0 + (hasHalfDay ? 4.0 : 0.0)
    }
    
    public init() {}
}

public struct TagsState: Equatable {
    public var isLoading: Bool = false
    public var userTagsResponse: UserTagsResponse?
    
    public var selectedBasicTags: Set<String> = []
    public var selectedCustomTags: Set<String> = []
    
    public var allBasicTags: [UserTag] = []
    public var allCustomTags: [UserTag] = []
    
    public var generalError: String?
    
    public var isSaving: Bool = false
    public var saveSuccess: Bool = false
    
    public var isFormValid: Bool {
        !isSaving && (!selectedBasicTags.isEmpty || !selectedCustomTags.isEmpty)
    }
    
    public var hasChanges: Bool {
        guard let response = userTagsResponse else { return false }
        
        let originalBasicTags = Set(response.selectedBasicTags.map { $0.content })
        let originalCustomTags = Set(response.selectedCustomTags.map { $0.content })
        
        return selectedBasicTags != originalBasicTags || selectedCustomTags != originalCustomTags
    }
    
    public init() {}
}

public enum ProfileAction {
    case loadUserProfile
    case userProfileLoaded(UserProfile)
    case loadUserProfileFailed(Error)
    case clearErrors
    case resetState
}

public enum ProfileEditAction {
    case initializeWithProfile(UserProfile)
    case updateNickname(String)
    case updateBirthDate(String)
    case saveProfile
    case profileSaved(UserProfile)
    case profileSaveFailed(Error)
    case clearErrors
    case resetState
}

public enum VacationAction {
    case initializeWithProfile(UserProfile)
    case updateRemainingDays(Int)
    case updateHasHalfDay(Bool)
    case saveVacationLeave
    case vacationLeaveSaved(VacationLeave)
    case vacationLeaveSaveFailed(Error)
    case clearErrors
    case resetState
}

public enum TagsAction {
    case loadUserTags
    case userTagsLoaded(UserTagsResponse)
    case loadUserTagsFailed(Error)
    
    case toggleBasicTag(String)
    case toggleCustomTag(String)
    case addCustomTag(String)
    case removeCustomTag(String)
    
    case saveTags
    case tagsSaved(UserTagsResponse)
    case tagsSaveFailed(Error)
    
    case clearErrors
    case resetState
}

public enum ProfileEffect {
    case showErrorMessage(String)
}

public enum ProfileEditEffect {
    case showSuccessMessage(String)
    case showErrorMessage(String)
    case navigateBack
}

public enum VacationEffect {
    case showSuccessMessage(String)
    case showErrorMessage(String)
    case navigateBack
}

public enum TagsEffect {
    case showSuccessMessage(String)
    case showErrorMessage(String)
    case navigateBack
    case showTagAddDialog
}
