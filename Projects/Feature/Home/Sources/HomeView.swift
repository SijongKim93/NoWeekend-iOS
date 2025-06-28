import DesignSystem
import Domain
import HomeInterface
import SwiftUI

public struct HomeView: View {
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            DS.Images.imgGradient
                .resizable()
                .frame(height: 260)
                .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                HStack {
                    Text("오늘 연차쓸래?")
                        .font(.heading4)
                        .foregroundColor(DS.Colors.Text.netural)
                        .padding(.top, 16)
                        .padding(.leading, 26)
                        .padding(.bottom, 8)
                    
                    Spacer()
                }
                .padding(.bottom, 32)
                
                
                HStack(spacing: 4) {
                    Text("평균 열정온도:")
                        .font(.body1)
                        .foregroundColor(DS.Colors.Text.body)
                    Text("97°C")
                        .font(.body1)
                        .foregroundColor(DS.Colors.Toast._600)
                }
                .padding(.bottom, 4)

                Text("온도를 식히는 휴식 어떠세요?")
                    .font(.heading4)
                    .foregroundColor(DS.Colors.Text.netural)

                DS.Images.imageMain
                    .resizable()
                    .frame(width: 140, height: 140)
                    .padding(.vertical, 16)

                NWButton.primary("최대 7일 휴가 굽기", action: {                   // TODO: 버튼 액션

                })
                .frame(width: 200, height: 60)


                Spacer()
            }
        }
    }
}

#Preview {
    HomeView()
}
