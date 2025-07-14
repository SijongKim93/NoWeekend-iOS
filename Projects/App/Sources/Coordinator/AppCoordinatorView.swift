//
//  AppCoordinatorView.swift
//  App
//
//  Created by 김시종 on 7/13/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI

@MainActor
public struct AppCoordinatorView: View {
    @StateObject private var coordinator = AppCoordinator()
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.view(coordinator.currentScreen)
                .navigationBarHidden(true)
                .navigationDestination(for: AppRouter.Screen.self) { screen in
                    coordinator.view(screen)
                        .environmentObject(coordinator)
                        .navigationBarHidden(true)
                }
                .sheet(item: $coordinator.sheet) { sheet in
                    NavigationView {
                        coordinator.presentView(sheet)
                            .environmentObject(coordinator)
                    }
                }
                .fullScreenCover(item: $coordinator.fullScreenCover) { cover in
                    coordinator.fullCoverView(cover)
                        .environmentObject(coordinator)
                }
        }
        .environmentObject(coordinator)
        .navigationBarHidden(true)
    }
}

