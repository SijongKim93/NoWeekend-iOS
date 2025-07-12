//
//  ShowToastView.swift
//  HomeFeature
//
//  Created by 김나희 on 7/12/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem

struct ShowToastView: View {
    @State private var isToastVisible = false
    let toastText: String
    let dateText: String

    var body: some View {
        ZStack {
            VStack {
                CustomNavigationBar(
                    type: .backOnly,
                    onBackTapped: {
                    }
                )
             
                Spacer()

                // 토스트 뷰
                Group {
                    if isToastVisible {
                        ToastContentView(
                            toastText: toastText,
                            dateText: dateText
                        )
                    } else {
                        LoadingContentView()
                    }
                }
                
                
                Spacer()
                DS.Images.imgToaster
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                isToastVisible = true
            }
        }
    }
}

struct ToastContentView: View {
    let toastText: String
    let dateText: String

    var body: some View {
        VStack(spacing: 20) {
            BalloonView(dateText: dateText)
            ToastView(isVisible: true, toastMessage: toastText)
                .animation(.easeInOut(duration: 0.5), value: true)
            HStack(spacing: 0) {
                Text("일정 볼래말래")
                    .font(.body1)
                    .foregroundColor(DS.Colors.Neutral.gray900)
                
                DS.Images.icnChevronRight
            }
            .frame(height: 24)
        }
    }
}

struct LoadingContentView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Text("휴가가 구워졌어요")
                .font(.heading4)
                .foregroundColor(DS.Colors.Text.netural)
            LottieView(type: JSONFiles.Loading.self)
                .frame(width: 200, height: 45)
                .padding(.top, 16)
            
            ToastView(isVisible: false, toastMessage: "")
        }
    }
}

struct ToastView: View {
    let isVisible: Bool
    let toastMessage: String

    @State private var offsetY: CGFloat = 360
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            DS.Images.imgToasterTrip
                .resizable()
                .scaledToFit()
            
            if isVisible {
                VStack(spacing: 0) {
                    Spacer(minLength: 86)
                    Text(toastMessage)
                        .font(.heading3)
                        .foregroundColor(DS.Colors.Toast._500)
                        .multilineTextAlignment(.center)
                        .truncationMode(.tail)
                }
                .padding(.leading, 48)
                .padding(.trailing, 62)
                .padding(.vertical, 20)
                .transition(.opacity)
            }
        }
        .offset(y: offsetY)
        .opacity(opacity)
        .frame(width: 260, height: 260)
        .onAppear {
            animateToast(visible: isVisible)
        }
        .onChange(of: isVisible) {
            animateToast(visible: isVisible)
        }
    }
    
    private func animateToast(visible: Bool) {
        if visible {
            withAnimation(.interpolatingSpring(stiffness: 120, damping: 12)) {
                offsetY = 0
                opacity = 1
            }
        } else {
            withAnimation(.easeIn(duration: 0.2)) {
                offsetY = 360
                opacity = 0
            }
        }
    }
}

struct BalloonView: View {
    let dateText: String
    
    var body: some View {
        ZStack {
            // 말풍선 배경 이미지
            DS.Images.imgBubble
                .resizable()
                .frame(width: 218, height: 65)
            
            HStack(spacing: 8) {
                Text(dateText)
                    .font(.heading6)
                    .foregroundColor(DS.Colors.Text.netural)
                DS.Images.icnPlus
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .padding(.top, 16)
            .padding(.bottom, 25)
        }
    }
}

#Preview {
    ShowToastView(toastText: "도쿄에 다코야키 먹으러 가요 타키 먹으러가야키 먹으러가야키 먹으러가야키 먹으러가요", dateText: "12/28(수) ~ 12/31(금)")
}
