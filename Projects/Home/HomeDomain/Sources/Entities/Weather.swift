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
    public let date: String
    public let message: String
    public let temperature: Double?
    public let weatherCondition: String?
    public let location: String?
    
    public init(
        id: String,
        date: String,
        message: String,
        temperature: Double? = nil,
        weatherCondition: String? = nil,
        location: String? = nil
    ) {
        self.id = id
        self.date = date
        self.message = message
        self.temperature = temperature
        self.weatherCondition = weatherCondition
        self.location = location
    }
}

public struct LocationRegistration: Codable, Equatable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
} 