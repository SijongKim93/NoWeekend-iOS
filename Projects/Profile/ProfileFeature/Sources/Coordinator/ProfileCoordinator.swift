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
    
    public typealias PushView = AnyView
    public typealias SheetView = AnyView
    public typealias FullView = AnyView
    
    @Published public var path: NavigationPath = NavigationPath()
    @Published public var sheet: SheetScreen?
    @Published public var fullScreenCover: FullScreen?
    
    public init() {}
    
    public func view(_ screen: Screen) -> AnyView {
        switch screen {
        case .home:
            return AnyView(ProfileView())
        case .edit:
            return AnyView(ProfileEditView())
        case .infoEdit:
            return AnyView(ProfileInfoDetailView())
        case .tags:
            return AnyView(ProfileTagsView())
        case .vacation:
            return AnyView(ProfileVacationView())
        case .serviceCall:
            return AnyView(ServiceCallView())
        case .policy:
            return AnyView(PrivatePolicyView())
        }
    }
    
    // MARK: - Sheet View
    public func presentView(_ sheet: SheetScreen) -> AnyView {
        switch sheet {
        case .tagResult(let selectedTags):
            return AnyView(ProfileTagResultView())
        case .category(let currentCategory):
            return AnyView(ProfileCategoryView())
        }
    }
    
    // MARK: - Full Screen View
    public func fullCoverView(_ cover: FullScreen) -> AnyView {
        switch cover {
        case .webView(let url):
            return AnyView(PrivatePolicyView())
        }
    }
    
    // MARK: - 편의 메서드
    public func presentFullScreen(url: String) {
        guard let url = URL(string: url) else { return }
        fullScreenCover = .webView(url)
    }
    
    public func dismissFullScreen() {
        fullScreenCover = nil
    }
    
    public func dismissSheet() {
        sheet = nil
    }
}
