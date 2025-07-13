//
//  WeatherDTO.swift
//  HomeData
//
//  Created by 김나희 on 2025/07/13.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import HomeDomain

// MARK: - API Response DTOs

struct ApiResponse<T: Codable>: Codable {
    let result: String
    let data: T?
    let error: String?
    
    init(result: String, data: T?, error: String?) {
        self.result = result
        self.data = data
        self.error = error
    }
}

struct WeatherRecommendResponseDTO: Codable {
    let weatherResponses: [WeatherItemDTO]
    
    init(weatherResponses: [WeatherItemDTO]) {
        self.weatherResponses = weatherResponses
    }
}

public struct WeatherItemDTO: Codable {
    let localDate: String
    let recommendContent: String
    
    init(localDate: String, recommendContent: String) {
        self.localDate = localDate
        self.recommendContent = recommendContent
    }
}

struct LocationRegistrationRequestDTO: Codable {
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - Mappers

extension WeatherItemDTO {
    func toDomain() -> Weather {
        return Weather(
            id: localDate,
            date: localDate,
            message: recommendContent
        )
    }
}

extension LocationRegistration {
    func toDTO() -> LocationRegistrationRequestDTO {
        return LocationRegistrationRequestDTO(
            latitude: latitude,
            longitude: longitude
        )
    }
} 
