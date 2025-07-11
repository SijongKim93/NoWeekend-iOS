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
            return AnyView(
                ProfileEditView(
                    onLoad: { [weak self] in
                        self?.loadProfileData() ?? (nickname: "", birthDate: "")
                    },
                    onSave: { [weak self] nickname, birthDate in
                        self?.saveProfileData(nickname: nickname, birthDate: birthDate)
                    }
                )
            )
        case .infoEdit:
            return AnyView(ProfileInfoDetailView())
        case .tags:
            return AnyView(ProfileTagsView())
        case .vacation:
            return AnyView(ProfileVacationView())
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
            return AnyView(ProfileVacationView()) //예시 수정해야함
        }
    }
    
    // MARK: - Business Logic
    private func loadProfileData() -> (nickname: String, birthDate: String) {
        // 실제 구현에서는 Repository나 UseCase를 통해 데이터 로드
        return (nickname: "김시종이", birthDate: "1990-01-01")
    }
    
    private func saveProfileData(nickname: String, birthDate: String) {
        // 실제 구현에서는 Repository나 UseCase를 통해 데이터 저장
        print("프로필 데이터 저장: \(nickname), \(birthDate)")
    }
}
