//
//  CoordinatorFactory.swift
//  NoWeekend
//
//  Created by 이지훈 on 7/3/25.
//

import CalendarFeature
import HomeFeature
import ProfileFeature
import SwiftUI

@MainActor
struct CoordinatorFactory {
    
    init() {}
    
    var homeCoordinatorRootView: some View {
        HomeCoordinatorView()
    }
    
    var profileCoordinatorRootView: some View {
        ProfileCoordinatorView()
    }
    
    var calendarCoordinatorRootView: some View {
        CalendarCoordinatorView()
    }
    
    var appCoordinatorRootView: some View {
        AppCoordinatorView()
    }
    
    static func createAppCoordinator() -> AppCoordinator {
        return AppCoordinator()
    }
}
