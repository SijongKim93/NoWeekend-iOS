//
//  HomeDemoApp.swift
//  HomeFeature
//
//  Created by 김나희 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import HomeFeature
import DataBridge
import DIContainer
import HomeData
import HomeDomain

@main
struct HomeDemoApp: App {
    
    init() {
        configureDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeCoordinatorView()
                .preferredColorScheme(.light)
        }
    }
    
    private func configureDependencies() {
        HomeDataModule.registerRepositories()
        HomeFeatureModule.registerUseCases()
    }
} 
