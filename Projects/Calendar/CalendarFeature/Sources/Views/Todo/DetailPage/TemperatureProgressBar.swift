//
//  TemperatureProgressBar.swift
//  CalendarFeature
//
//  Created by 이지훈 on 7/13/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import DesignSystem
import SwiftUI

struct TemperatureProgressBar: View {
    let temperature: Int
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(DS.Colors.Neutral.gray100)
                        .frame(height: 16)
                    
                    RoundedRectangle(cornerRadius: 0)
                        .fill(DS.Colors.Toast._400)
                        .frame(width: geometry.size.width * CGFloat(temperature) / 100, height: 16)
                    
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(DS.Colors.Toast._800)
                            .frame(width: 1, height: 16)
                        
                        Spacer()
                        
                        Rectangle()
                            .fill(DS.Colors.Toast._800)
                            .frame(width: 1, height: 16)
                        
                        Spacer()
                        
                        Rectangle()
                            .fill(DS.Colors.Toast._800)
                            .frame(width: 1, height: 16)
                        
                        Spacer()
                        
                        Rectangle()
                            .fill(DS.Colors.Toast._800)
                            .frame(width: 1, height: 16)
                    }
                }
            }
            .frame(height: 16)
            
            HStack(spacing: 0) {
                Text("0°C")
                    .font(.body3)
                    .foregroundColor(DS.Colors.Text.disable)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("25°C")
                    .font(.body3)
                    .foregroundColor(DS.Colors.Text.disable)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("50°C")
                    .font(.body3)
                    .foregroundColor(DS.Colors.Text.disable)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("100°C")
                    .font(.body3)
                    .foregroundColor(DS.Colors.Text.disable)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}
