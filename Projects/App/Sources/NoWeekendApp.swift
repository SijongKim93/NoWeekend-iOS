//
//  NoWeekendApp.swift
//  NoWeekend
//
//  Created by 이지훈 on 7/3/25.
//

import SwiftUI

@main
struct NoWeekendApp: App {
    
    init() {
        AppDependencyConfiguration.configure()
    }
    
    var body: some Scene {
        @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
        
        WindowGroup {
            ContentView()
        }
    }
}
