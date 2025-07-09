//
//  HomeRepositoryProtocol.swift
//  HomeDomain
//
//  Created by 이지훈 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public protocol HomeRepositoryProtocol {
    func getHomes() async throws -> [Home]
    func createHome(_ home: Home) async throws
    func deleteHome(id: String) async throws
} 