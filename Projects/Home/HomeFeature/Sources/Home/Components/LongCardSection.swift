//
//  HomeView.swift
//  HomeFeature
//
//  Created by 김나희 on 7/9/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem

struct LongCardSection: View {
    @Binding var currentPage: Int
    let cards: [VacationCardItem]
    var onCardTapped: ((VacationCardType) -> Void)? = nil
    
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
                ForEach(cards.indices, id: \.self) { idx in
                    let cardData = cards[idx]
                    VacationCardView(
                        vactionType: cardData.type,
                        variableText: cardData.dateString,
                        attributedText: cardData.attributedText,
                        onTap: {
                            onCardTapped?(cardData.type)
                        }
                    )
                    .tag(idx)
                    .padding(.horizontal)
                }
            }
            .frame(height: 100)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            PageControl(currentPage: $currentPage, numberOfPages: cards.count)
                .padding(.top, 16)
                .padding(.bottom, 24)
                .frame(alignment: .center)
                .frame(maxWidth: .infinity)
        }
    }
} 
