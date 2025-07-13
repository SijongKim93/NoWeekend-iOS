//
//  TemperatureCard.swift
//  CalendarFeature
//
//  Created by 이지훈 on 7/13/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import DesignSystem
import SwiftUI

struct TemperatureCard: View {
    let temperature: Int
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            temperatureImage(temperature)
                .resizable()
                .scaledToFill()
                .clipped()
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("오늘의 열정 온도")
                        .font(.heading5)
                        .foregroundColor(DS.Colors.Neutral.black)
                    
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("\(temperature)")
                            .font(.heading2)
                            .foregroundColor(DS.Colors.TaskItem.orange)
                        
                        Text("°C")
                            .font(.heading6)
                            .foregroundColor(DS.Colors.TaskItem.orange)
                            .padding(.bottom,8)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 24)
            .padding(.leading, 24)
        }
        .frame(height: 195)
    }
    
    private func temperatureImage(_ temperature: Int) -> Image {
        switch temperature {
        case 0...25: return DS.Images.imgFlour
        case 26...50: return DS.Images.imgHotbread
        case 51...100: return DS.Images.imgBurnBread
        default: return DS.Images.imgGridenteBread
        }
    }
}
