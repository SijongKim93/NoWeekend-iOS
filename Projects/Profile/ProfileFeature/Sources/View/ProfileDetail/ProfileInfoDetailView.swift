//
//  ProfileInfoDetailView.swift (즉시 네비게이션 초기화)
//  ProfileFeature
//

import DesignSystem
import DIContainer
import SwiftUI
import Combine
import LoginFeature

struct ProfileInfoDetailView: View {
    @EnvironmentObject var coordinator: ProfileCoordinator
    @ObservedObject var store: ProfileStore
    @ObservedObject var loginStore: LoginStore
    
    @State private var showingLogoutAlert = false
    @State private var showingWithdrawalAlert = false
    
    public init() {
        self.store = DIContainer.shared.resolve(ProfileStore.self)
        self.loginStore = DIContainer.shared.resolve(LoginStore.self)
        print("🏗️ ProfileInfoDetailView - LoginStore 주입 완료")
    }
    
    public var body: some View {
        VStack {
            InfoDetailHeaderSection()
            InfoDetailSettingSection(
                store: store,
                showingLogoutAlert: $showingLogoutAlert,
                showingWithdrawalAlert: $showingWithdrawalAlert,
                loginStore: loginStore,
                coordinator: coordinator
            )
            
            Spacer()
            
            Button(action: {
                showingWithdrawalAlert = true
            }, label: {
                HStack {
                    Text("계정 삭제")
                        .font(.body1)
                        .foregroundColor(DS.Colors.Text.body)
                    
                    DS.Images.icnChevronRight
                        .tint(DS.Colors.Text.body)
                }
            })
        }
        .alert("로그아웃", isPresented: $showingLogoutAlert) {
            Button("취소", role: .cancel) {
            }
            Button("로그아웃", role: .destructive) {
                handleLogoutConfirm()
            }
        } message: {
            Text("정말 로그아웃 하시겠습니까?")
        }
        .alert("정말로 앱을 떠나시나요?", isPresented: $showingWithdrawalAlert) {
            Button("취소", role: .cancel) {
            }
            Button("계정 삭제", role: .destructive) {
                handleWithdrawalConfirm()
            }
        } message: {
            Text("삭제하시면 모든 정보가 복구되지 않으며,\n이용 기록이 사라집니다.")
        }
    }
    
    private func handleLogoutConfirm() {
        
        DispatchQueue.main.async {
            self.coordinator.popToRoot()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.loginStore.send(.signOut)
            }
        }
    }
    
    private func handleWithdrawalConfirm() {
        DispatchQueue.main.async {
            self.coordinator.popToRoot()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.loginStore.send(.withdrawAppleAccount)
            }
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
    let store: ProfileStore
    @Binding var showingLogoutAlert: Bool
    @Binding var showingWithdrawalAlert: Bool
    let loginStore: LoginStore
    let coordinator: ProfileCoordinator
    
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
        showingLogoutAlert = true
    }
    
    private func handleWithdrawal() {
        showingWithdrawalAlert = true
    }
    
    private var isAppleAccount: Bool {
        guard let profile = store.state.userProfile else { return false }
        return profile.providerType == .apple
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
            return DS.Images.icon
        }
    }
}

#Preview {
    ProfileInfoDetailView()
}
