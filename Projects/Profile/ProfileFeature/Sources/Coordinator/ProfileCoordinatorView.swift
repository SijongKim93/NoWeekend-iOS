//
//  ProfileCoordinatorView.swift
//  ProfileFeature
//
//  Created by SiJongKim on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI

public struct ProfileCoordinatorView: View {
    @StateObject private var coordinator = ProfileCoordinator()
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.view(.home)
                .navigationBarHidden(true)
                .navigationDestination(for: ProfileRouter.Screen.self) { screen in
                    coordinator.view(screen)
                        .environmentObject(coordinator)
                        .navigationBarHidden(true)
                }
                .sheet(item: $coordinator.sheet) { sheet in
                    NavigationView {
                        coordinator.presentView(sheet)
                            .environmentObject(coordinator)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("닫기") {
                                        coordinator.dismissSheet()
                                    }
                                }
                            }
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
