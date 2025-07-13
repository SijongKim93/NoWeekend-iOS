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
    init() {}
    
    var body: some View {
        AppCoordinatorView()
    }
}


// 임시, 언제든 삭제 가능 현재 런치스크린 이전에 남겨둠
struct LoadingView: View {
    var body: some View {
        Text("Loading...")
    }
}

#Preview {
    ContentView()
}
