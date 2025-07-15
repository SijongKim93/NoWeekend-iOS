//
//  PrivatePolicy.swift
//  ProfileFeature
//
//  Created by 김시종 on 7/15/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import DesignSystem
import SwiftUI
import WebKit

public struct PrivatePolicyView: View {
    @EnvironmentObject var coordinator: ProfileCoordinator
    @State private var isLoading = true
    @State private var loadingError: Error?
    
    private let policyURL = "https://sticky-gymnast-69e.notion.site/231f96d0be9c800cb85adf85e9bbed77"
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            navigationBar
            webViewContent
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    private var navigationBar: some View {
        CustomNavigationBar(
            type: .backWithLabel("정책"),
            onBackTapped: {
                coordinator.pop()
            }
        )
    }
    
    private var webViewContent: some View {
        ZStack {
            // 웹뷰
            if let url = URL(string: policyURL) {
                WebViewRepresentable(
                    url: url,
                    isLoading: $isLoading,
                    error: $loadingError
                )
            }
            
            // 로딩 인디케이터
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    
                    Text("로딩 중...")
                        .font(.body2)
                        .foregroundColor(DS.Colors.Text.body)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(DS.Colors.Background.alternative01)
            }
            
            // 에러 화면
            if let error = loadingError {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(DS.Colors.Text.body)
                    
                    Text("페이지를 불러올 수 없습니다")
                        .font(.heading5)
                        .foregroundColor(DS.Colors.Text.netural)
                    
                    Text(error.localizedDescription)
                        .font(.body2)
                        .foregroundColor(DS.Colors.Text.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    Button("다시 시도") {
                        loadingError = nil
                        isLoading = true
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(DS.Colors.Background.alternative01)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(DS.Colors.Background.alternative01)
            }
        }
    }
}
