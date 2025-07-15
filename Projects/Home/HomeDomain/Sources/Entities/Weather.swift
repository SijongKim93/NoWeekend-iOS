//
//  Weather.swift
//  HomeDomain
//
//  Created by 김나희 on 2025/07/13.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public struct Weather: Codable, Identifiable, Equatable {
    public let id: String
    public let localDate: String
    public let recommendContent: String
    public let temperature: Double?
    public let weatherCondition: String?
    public let location: String?
    
    public init(
        id: String,
        localDate: String,
        recommendContent: String,
        temperature: Double? = nil,
        weatherCondition: String? = nil,
        location: String? = nil
    ) {
        self.id = id
        self.localDate = localDate
        self.recommendContent = recommendContent
        self.temperature = temperature
        self.weatherCondition = weatherCondition
        self.location = location
    }
    
    // 기존 코드와의 호환성을 위한 computed properties
    public var date: String { localDate }
    public var message: String { recommendContent }
}

public struct LocationRegistration: Codable, Equatable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
} 