//
//  MypageInfoDetailView.swift
//  Mypage
//
//  Created by SiJongKim on 7/4/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem

struct ProfileInfoDetailView: View {
    @EnvironmentObject var coordinator: ProfileCoordinator
    
    public init() {}
    
    public var body: some View {
        VStack {
            InfoDetailHeaderSection()
            InfoDetailSettingSection()
            
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
    var body: some View {
        VStack(spacing: 16) {
            SettingRow.withRightText(
                title: "계정",
                rightText: "김매숑",
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
            
            // 오른쪽 텍스트 및 아이콘 상태에 맞춰 수정해야함
            SettingRow.withIconAndRightText(
                title: "로그아웃",
                rightText: "구글 계정",
                rightIcon: DS.Images.icon1,
                action: {
                    handleLogout()
                }
            )
        }
    }
    
    private func handleLogout() {
        print("로그아웃 처리 (알럿, 상태 변경, 토큰삭제 등 들어가야함")
    }
}

private struct InfoDetailBottomSection: View {
    var body: some View {
        Text("InfoDetailBottom")
    }
}
