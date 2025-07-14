//
//  HomeUseCaseProtocol.swift
//  HomeDomain
//
//  Created by 이지훈 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public protocol HomeUseCaseProtocol {
    func getHomes() async throws -> [Home]
    func createHome(title: String, date: Date, description: String?) async throws
    func deleteHome(id: String) async throws
    func getUpcomingHomes() async throws -> [Home]
    
    // 위치 및 날씨 관련
    func registerLocation(latitude: Double, longitude: Double) async throws
    func getWeatherRecommendations() async throws -> [Weather]
    
    // 샌드위치 휴일 및 공휴일 관련
    func getSandwichHoliday() async throws -> [SandwichHoliday]
    func getHolidays() async throws -> [Holiday]
} 