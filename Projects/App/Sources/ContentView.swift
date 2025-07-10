//
//  ContentView.swift
//  NoWeekend
//
//  Created by 이지훈 on 7/3/25.
//

import CalendarFeature
import DesignSystem
import HomeFeature
import LoginFeature
import OnboardingFeature
import ProfileFeature
import SwiftUI

@MainActor
struct ContentView: View {
    @State private var appState = AppState()
    
    init() {}
    
    var body: some View {
        currentView
            .onAppear {
                appState.checkLoginStatus()
            }
    }

    @ViewBuilder
    private var currentView: some View {
        if appState.isLoading {
            LoadingView()
        } else if !appState.isLoggedIn {
            LoginView()
        } else if !appState.isOnboardingCompleted {
            
        } else {
            TabBarView()
        }
    }
}

struct LoadingView: View {
    var body: some View {
        Text("Loading...")
    }
}

#Preview {
    ContentView()
}
