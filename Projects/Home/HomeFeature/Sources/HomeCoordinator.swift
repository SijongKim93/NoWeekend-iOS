//
//  HomeCoordinator.swift
//  HomeFeature
//
//  Created by 이지훈 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Coordinator
import SwiftUI

final class HomeCoordinator: ObservableObject, Coordinatorable {
    typealias Screen = HomeRouter.Screen
    typealias SheetScreen = HomeRouter.Sheet
    typealias FullScreen = HomeRouter.FullScreen
    
    @Published var path: NavigationPath = NavigationPath()
    @Published var sheet: SheetScreen?
    @Published var fullScreenCover: FullScreen?
    
    var onVacationBakingCompleted: (() -> Void)?
    var remainingAnnualLeave: Int = 0
    
    init() {}
    
    @ViewBuilder
    func view(_ screen: Screen) -> some View {
        switch screen {
        case .main:
            HomeView()
        case .vacationBaking:
            VacationBakingView(
                remainingAnnualLeave: remainingAnnualLeave,
                onCompleted: {
                    self.onVacationBakingCompleted?()
                }
            )
        }
    }
    
    @ViewBuilder
    func presentView(_ sheet: SheetScreen) -> some View {
        EmptyView()
    }
    
    @ViewBuilder
    func fullCoverView(_ cover: FullScreen) -> some View {
        EmptyView()
    }
}

enum HomeRouter {
    enum Screen: Hashable {
        case main
        case vacationBaking
    }
    
    enum Sheet: String, Identifiable {
        case dummy
        var id: String { self.rawValue }
    }
    
    enum FullScreen: String, Identifiable {
        case dummy
        var id: String { self.rawValue }
    }
}
