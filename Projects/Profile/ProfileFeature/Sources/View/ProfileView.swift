import SwiftUI
import ProfileDomain
import DesignSystem

public struct ProfileView: View {
    var isToggle: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack {
            MypageHeaderSection()
            MypageVacationSection()
            MypageSettingSection()
            
            Spacer()
        }
    }
    
}

private struct MypageHeaderSection: View {
    var body: some View {
        HStack(alignment:.center) {
            Text("김시종이")
                .font(.heading4)
                .foregroundColor(DS.Colors.Text.netural)//netural
            
            Spacer()
            
            Button {
                print("프로필 정보 수정 버튼")
            } label: {
                Text("수정")
                    .font(.body2)
                    .foregroundColor(DS.Colors.Text.body)//body
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .padding(.horizontal, 24)
        
    }
}

private struct MypageVacationSection: View {
    var body: some View {
        statusCardView
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(height: 124)
    }
    
    var statusCardView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(DS.Colors.Background.alternative01)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(DS.Colors.Border.border02)
                )
            
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("남은 연차")
                        .font(.body2)
                        .foregroundColor(DS.Colors.Text.netural)
                    
                    Text("10.5")
                        .font(.heading5)
                        .foregroundColor(DS.Colors.Text.netural)
                }
                .frame(maxWidth: .infinity)
                
                Rectangle()
                    .fill(DS.Colors.Border.border02)
                    .frame(width: 1, height: 24)
                
                VStack(spacing: 4) {
                    Text("사용한 연차")
                        .font(.body2)
                        .foregroundColor(DS.Colors.Text.netural)//netural
                    
                    Text("3")
                        .font(.heading5)
                        .foregroundColor(DS.Colors.Text.netural)//netural
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 40)
        }
    }
}

private struct MypageSettingSection: View {
    var body: some View {
        VStack(spacing: 32) {
            SettingSection(
                title: "정보") {
                    SettingRow.basic(title: "연차 관리") {
                        
                    }
                    
                    SettingDivider()
                    
                    SettingRow.withRightTextOnly(
                        title: "기본 카테고리",
                        titleFont: .body1,
                        rightText: "개인",
                        color: DS.Colors.TaskItem.orange
                    ) //선택한 카테고리값 적용해야함
                    
                    SettingDivider()
    
//                    SettingRow.basic(title: "알림 설정") {
//                        
//                    }
                    
                }
            
            SettingSection(
                title: "기타") {
                    SettingRow.basic(title: "서비스 문의") {
                        
                    }
                    
                    SettingDivider()
                    
                    SettingRow.basic(title: "정책") {
                        
                    }
                    
                    SettingDivider()
                    
                    SettingRow.withRightTextOnly(
                        title: "현재 버전",
                        titleFont: .heading6,
                        rightText: "v. 1.0"
                    )
                }
        }
    }
}



#Preview {
    ProfileView()
}
