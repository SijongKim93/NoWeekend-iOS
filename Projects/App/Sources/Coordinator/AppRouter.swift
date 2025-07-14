//
//  AppRouter.swift
//  App
//
//  Created by 김시종 on 7/13/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public enum AppRouter {
    public enum Screen: Hashable {
        case login
        case onboarding
        case main
    }
    
    public enum Sheet: String, RawRepresentable, Identifiable, CaseIterable {
        case none
        
        public var id: String { rawValue }
    }
    
    public enum FullScreen: String, RawRepresentable, Identifiable, CaseIterable {
        case none
        
        public var id: String { rawValue }
    }
}
