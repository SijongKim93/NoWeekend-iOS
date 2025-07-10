//
//  ProfileCoordinator.swift
//  ProfileFeature
//
//  Created by 김시종 on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Combine
import Coordinator
import SwiftUI

public final class ProfileCoordinator: ObservableObject, Coordinatorable {
    
    public typealias Screen = ProfileRouter.Screen
    public typealias SheetScreen = ProfileRouter.Sheet
    public typealias FullScreen = ProfileRouter.FullScreen
    
    @Published public var path: NavigationPath = NavigationPath()
    @Published public var sheet: SheetScreen?
    @Published public var fullScreenCover: FullScreen?
    
    public init() {
        print("🧭 ProfileCoordinator 생성")
    }
    
    @ViewBuilder
    public func view(_ screen: Screen) -> some View {
        switch screen {
        case .home:
            ProfileView()
        case .edit:
            ProfileEditView()
        case .infoEdit:
            ProfileInfoDetailView()
        case .tags:
            
        case .vacation:
            
        }
    }
    
    @ViewBuilder
    public func presentView(_ sheet: SheetScreen) -> some View {
        switch sheet {
        case .tagResult(let selectedTags):
            
        case .category(let currentCategory):
            
        }
    }
    
    @ViewBuilder
    public func fullCoverView(_ cover: FullScreen) -> some View {
        switch cover {
        case .webView(let url):
            
        }
    }
}

public enum ProfileRouter {
    public enum Screen: Hashable {
        case home
        case edit
        case infoEdit
        case tags
        case vacation
    }
    
    public enum Sheet: Identifiable {
        case tagResult(selectedTags: [String])
        case category(currentCategory: String)
        
        public var id: String {
            switch self {
            case .tagResult:
                return "tagResult"
            case .category:
                return "category"
            }
        }
    }
    
    public enum FullScreen: Identifiable {
        case webView(URL)
        
        public var id: String {
            switch self {
            case .webView(let url):
                return "webView_\(url.absoluteString)"
            }
        }
    }
}
