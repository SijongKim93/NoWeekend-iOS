//
//  MypageInfoDetailView.swift
//  Mypage
//
//  Created by SiJongKim on 7/4/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import DesignSystem
import DIContainer
import SwiftUI

struct ProfileInfoDetailView: View {
    @EnvironmentObject var coordinator: ProfileCoordinator
    @ObservedObject var store: ProfileStore
    
    public init() {
        self.store = DIContainer.shared.resolve(ProfileStore.self)
    }
    
    public var body: some View {
        VStack {
            InfoDetailHeaderSection()
            InfoDetailSettingSection(store: store)
            
            Spacer()
        }
    }
}

private struct InfoDetailHeaderSection: View {
    @EnvironmentObject var coordinator: ProfileCoordinator
    var body: some View {
        VStack {
            CustomNavigationBar(
                type: .backWithLabel("정보 수정"),
                onBackTapped: {
                    coordinator.pop()
                }
            )
        }
    }
}

private struct InfoDetailSettingSection: View {
    @EnvironmentObject var coordinator: ProfileCoordinator
    let store: ProfileStore
    
    var body: some View {
        VStack(spacing: 16) {
            SettingRow.withRightText(
                title: "계정",
                rightText: store.displayNickname,
                action: {
                    coordinator.push(.edit)
                }
            )
            
            SettingDivider()
            
            SettingRow.basicWithArrow(
                title: "자주하는 일정",
                action: {
                    coordinator.push(.tags)
                }
            )
            
            SettingDivider()
            
            SettingRow.withIconAndRightText(
                title: "로그아웃",
                rightText: store.providerDisplayText,
                rightIcon: providerIcon,
                action: {
                    handleLogout()
                }
            )
        }
    }
    
    private func handleLogout() {
        print("로그아웃 처리 (알럿, 상태 변경, 토큰삭제 등 들어가야함")
    }
    
    private var providerIcon: Image {
        guard let profile = store.state.userProfile else {
            return DS.Images.icon1
        }
        
        switch profile.providerType {
        case .google:
            return DS.Images.icon1
        case .apple:
            return DS.Images.icon
        @unknown default:
            return DS.Images.icon1
        }
    }
    
}

private struct InfoDetailBottomSection: View {
    var body: some View {
        Text("InfoDetailBottom")
    }
}

#Preview {
    ProfileInfoDetailView()
}
