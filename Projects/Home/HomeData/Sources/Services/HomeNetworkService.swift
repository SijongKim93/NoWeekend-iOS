//
//  HomeNetworkService.swift
//  HomeData
//
//  Created by 김나희 on 2025/01/13.
//

import Foundation
import NWNetwork
import HomeDomain

public protocol HomeNetworkServiceProtocol {
    func registerLocation(_ location: LocationRegistration) async throws
    func getWeatherRecommendations() async throws -> [WeatherItemDTO]
}

public final class HomeNetworkService: HomeNetworkServiceProtocol {
    private let networkService: NWNetworkServiceProtocol

    public init(networkService: NWNetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func registerLocation(_ location: LocationRegistration) async throws {
        let dto = location.toDTO()
        let parameters: [String: Any] = [
            "latitude": dto.latitude,
            "longitude": dto.longitude
        ]
        let _: ApiResponse<String> = try await networkService.post(
            endpoint: HomeEndpoint.registerLocation.path,
            parameters: parameters
        )
    }

    public func getWeatherRecommendations() async throws -> [WeatherItemDTO] {
        let response: ApiResponse<WeatherRecommendResponseDTO> = try await networkService.get(
            endpoint: HomeEndpoint.getWeatherRecommendations.path,
            parameters: nil
        )
        return response.data?.weatherResponses ?? []
    }
} 