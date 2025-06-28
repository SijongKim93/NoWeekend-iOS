import DesignSystem
import Domain
import HomeInterface
import SwiftUI

public struct HomeView: View {
    @State private var currentLongCardPage: Int = 0
    @State private var currentShortCardPage: Int = 0
    
    let longCards: [(VacationCardType, String)] = [
        (.trip, "0/00(월) ~ 0/00(월)"),
        (.home, "0/00(월) ~ 0/00(월)")
    ]
    
    let shortCards: [(VacationCardType, String)] = [
        (.sandwich, "0/00(월) ~ 0/00(월)"),
        (.birthday, "0/00(월)"),
        (.holiday, "0/00(월)"),
        (.friday, "0/00(월)")
    ]

    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            DS.Images.imgGradient
                .resizable()
                .frame(height: 260)
                .ignoresSafeArea(edges: .top)
                .zIndex(0)

            ScrollView {
                VStack(spacing: 0) {
                    MainTopView()
                        .zIndex(1)
                    
                    VStack {
                        Spacer(minLength: 48)
                        LongCardSection(currentPage: $currentLongCardPage, longCards: longCards)
                            .background(DS.Colors.Background.alternative01)
                        Spacer(minLength: 48)
                        WeekVacation()
                        Spacer(minLength: 48)
                        ShortCardSection(currentPage: $currentShortCardPage, shortCards: shortCards)
                        Spacer()
                    }
                    .background(DS.Colors.Background.normal)
                }
            }
        }
    }
}

// MARK: - 상단 메인 뷰
private struct MainTopView: View {
    var body: some View {
       
        VStack(spacing: 0) {
            HStack {
                Text("오늘 연차쓸래?")
                    .font(.heading4)
                    .foregroundColor(DS.Colors.Text.netural)
                    .padding(.leading, 26)
                    .padding(.bottom, 8)
                
                Spacer()
            }
            .padding(.top, 16)
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
            
            NWButton.primary("최대 7일 휴가 굽기", action: { })
                .frame(width: 200, height: 60)
        }
    }
}

// MARK: - 추천 휴가
private struct LongCardSection: View {
    @Binding var currentPage: Int
    let longCards: [(VacationCardType, String)]
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("dbsk님을 위한 ")
                + Text("일").foregroundColor(DS.Colors.Toast._600)
                + Text(" 휴가예요")
                Spacer()
            }
            .font(.heading5)
            .padding(.vertical, 24)
            .padding(.horizontal, 24)
            
            TabView(selection: $currentPage) {
                ForEach(longCards.indices, id: \.self) { idx in
                    let card = longCards[idx].0
                    let subtitle = longCards[idx].1
                    VacationCardView(
                        vactionType: card,
                        variableText: subtitle,
                        onTap: {}
                    )
                    .tag(idx)
                    .padding(.horizontal)
                }
            }
            .frame(height: 100)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            PageControl(currentPage: $currentPage, numberOfPages: longCards.count)
                .padding(.top, 16)
                .padding(.bottom, 24)
                .frame(alignment: .center)
                .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - -째주 휴가
struct WeekVacation: View {
    var body: some View {
        VStack {
            HStack {
                Text("6월 첫째주 휴가를 추천드려요")
                    .font(.heading5)
                Spacer()
            }
            .padding(.horizontal, 24)
            
            WeekCalendarView(cellContent: {_ in
                DS.Images.imgToastVacation
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38)
            })
        }
    }
}

// MARK: - 인기휴가
private struct ShortCardSection: View {
    @Binding var currentPage: Int

    let shortCards: [(VacationCardType, String)]
    var body: some View {
        VStack {
            HStack {
                Text("인기 휴가, 모두 확인하세요")
                    .font(.heading5)
                Spacer()
            }
            
            HStack {
                NWButton(variant: .primary, size: .md, action: {}) {
                    HStack {
                        Text("2025년 6월")
                            .font(.subtitle1)
                        DS.Images.icnChevronDown
                    }
                }
                .frame(width: 114)
                
                Spacer()
            }
            .padding(.top, 22)
            .padding(.bottom, 16)
                       
            
            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
                ForEach(shortCards.indices, id: \.self) { idx in
                    let card = shortCards[idx].0
                    let subtitle = shortCards[idx].1
                    VacationCardView(
                        vactionType: card,
                        variableText: subtitle,
                        onTap: {}
                    )
                }
            }
        }
        .padding(.horizontal)
    
        PageControl(currentPage: $currentPage, numberOfPages: (shortCards.count/4))
            .padding(.top, 16)
            .padding(.bottom, 24)
            .frame(alignment: .center)
            .frame(maxWidth: .infinity)
    }
}


#Preview {
    HomeView()
}
