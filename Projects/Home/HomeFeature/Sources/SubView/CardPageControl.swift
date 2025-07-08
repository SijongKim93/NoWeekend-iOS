//
//  CardPageControl.swift
//  Home
//
//  Created by 김나희 on 6/29/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI

struct PageControl: View {
    @Binding var currentPage: Int
    let numberOfPages: Int
    var activeColor: Color = .orange
    var inactiveColor: Color = Color(.systemGray4)
    var size: CGFloat = 8
    var spacing: CGFloat = 8

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? activeColor : inactiveColor)
                    .frame(width: size, height: size)
                    .animation(.easeInOut, value: currentPage)
            }
        }
    }
}
