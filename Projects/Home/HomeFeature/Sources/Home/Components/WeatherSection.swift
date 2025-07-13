//
//  WeatherSection.swift
//  HomeFeature
//
//  Created by 김나희 on 2025/07/13.
//

import SwiftUI
import DesignSystem
import HomeDomain

struct WeatherSection: View {
    let weatherData: [Weather]
    let isLoading: Bool
    let onPlusTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isLoading {
                ProgressView()
            } else if weatherData.isEmpty {
                Text("위치를 등록하면 날씨 기반 휴가를 추천해드려요")
                    .font(.body2)
                    .foregroundColor(DS.Colors.Text.disable)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(weatherData) { weather in
                        WeatherItemView(weather: weather)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .background(DS.Colors.Neutral.white)
    }
}

struct WeatherItemView: View {
    let weather: Weather

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(weather.date)
                .font(.caption)
                .foregroundColor(DS.Colors.Text.disable)
            Text(weather.message)
                .font(.body2)
                .foregroundColor(DS.Colors.Text.netural)
                .lineLimit(2)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(DS.Colors.Background.alternative01)
        .cornerRadius(8)
    }
}

#Preview {
    WeatherSection(
        weatherData: [
            Weather(id: "1", date: "오늘", message: "맑은 날씨에 드라이브하기 좋은 날이에요"),
            Weather(id: "2", date: "내일", message: "비가 올 예정이니 실내 활동을 추천해요")
        ],
        isLoading: false,
        onPlusTapped: {}
    )
}
