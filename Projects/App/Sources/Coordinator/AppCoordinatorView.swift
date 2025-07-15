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
    @EnvironmentObject var coordinator: AppCoordinator
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.view(coordinator.rootScreen)
                .navigationBarHidden(true)
                .navigationDestination(for: AppRouter.Screen.self) { screen in
                    coordinator.view(screen)
                        .environmentObject(coordinator)
                        .navigationBarHidden(true)
                        // 🎯 NavigationStack 기본 애니메이션 유지 (오른쪽→왼쪽)
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
        .navigationBarHidden(true)
        // 🎬 방향에 따른 정확한 전환
        .transition(
            coordinator.transitionDirection == .forward
                ? .rightToLeft
                : .leftToRight
        )
        .animation(.easeInOut(duration: 0.3), value: coordinator.rootScreen)
        .animation(.easeInOut(duration: 0.1), value: coordinator.transitionDirection)
    }
}

// MARK: - 🎬 명확한 방향성 Transitions

extension AnyTransition {
    
    // 🎯 오른쪽→왼쪽 진행 (모든 forward 이동)
    static var rightToLeft: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity), // 오른쪽에서 들어옴
            removal: .move(edge: .leading).combined(with: .opacity)     // 왼쪽으로 사라짐
        )
    }
    
    // 🔄 왼쪽→오른쪽 되돌아가기 (모든 backward 이동)
    static var leftToRight: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),  // 왼쪽에서 들어옴
            removal: .move(edge: .trailing).combined(with: .opacity)    // 오른쪽으로 사라짐
        )
    }
}
