//
//  Modules.swift
//  ProjectDescriptionHelpers
//
//  Created by 김시종 on 6/16/25.
//

import ProjectDescription

// MARK: - Project Paths (업데이트된 구조)
public enum ProjectPath: String, CaseIterable {
    case app = "Projects/App"
    case core = "Projects/Core"
    case shared = "Projects/Shared"
    case plugin = "Projects/Plugin"
    
    // Feature별 모듈들
    case loginFeature = "Projects/Login/LoginFeature"
    case loginDomain = "Projects/Login/LoginDomain"
    case loginData = "Projects/Login/LoginData"
    
    case homeFeature = "Projects/Home/HomeFeature"
    case homeDomain = "Projects/Home/HomeDomain"
    case homeData = "Projects/Home/HomeData"
    
    case profileFeature = "Projects/Profile/ProfileFeature"
    case profileDomain = "Projects/Profile/ProfileDomain"
    case profileData = "Projects/Profile/ProfileData"
    
    case calendarFeature = "Projects/Calendar/CalendarFeature"
    case calendarDomain = "Projects/Calendar/CalendarDomain"
    case calendarData = "Projects/Calendar/CalendarData"
    
    case onboardingFeature = "Projects/Onboarding/OnboardingFeature"
    case onboardingDomain = "Projects/Onboarding/OnboardingDomain"
    case onboardingData = "Projects/Onboarding/OnboardingData"
    
    public var relativePath: Path {
        .relativeToRoot(self.rawValue)
    }
}

// MARK: - External Dependencies
public enum ExternalDependency: String, CaseIterable {
    case alamofire = "Alamofire"
    case lottie = "Lottie"
    case swinject = "Swinject"
    case googleSignIn = "GoogleSignIn"
}

// MARK: - Feature Modules (정리된 구조)
public enum FeatureModule: String, CaseIterable {
    // Login
    case loginFeature = "LoginFeature"
    case loginDomain = "LoginDomain"
    case loginData = "LoginData"
    
    // Home
    case homeFeature = "HomeFeature"
    case homeDomain = "HomeDomain"
    case homeData = "HomeData"
    
    // Profile
    case profileFeature = "ProfileFeature"
    case profileDomain = "ProfileDomain"
    case profileData = "ProfileData"
    
    // Calendar
    case calendarFeature = "CalendarFeature"
    case calendarDomain = "CalendarDomain"
    case calendarData = "CalendarData"
    
    // Onboarding
    case onboardingFeature = "OnboardingFeature"
    case onboardingDomain = "OnboardingDomain"
    case onboardingData = "OnboardingData"
}

// MARK: - Shared Modules
public enum SharedModule: String, CaseIterable {
    case utils = "Utils"
    case designSystem = "DesignSystem"
}

// MARK: - Core Modules
public enum CoreModule: String, CaseIterable {
    case nwnetwork = "NWNetwork"
    case diContainer = "DIContainer"
    case coordinator = "Coordinator"
}

// MARK: - Plugin Modules
public enum PluginModule: String, CaseIterable {
    case analytics = "Analytics"
    case push = "Push"
    case thirdParty = "ThirdParty"
}
