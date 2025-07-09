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
} 