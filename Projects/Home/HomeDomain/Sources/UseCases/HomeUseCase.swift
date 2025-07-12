//
//  HomeUseCaseProtocol.swift
//  HomeDomain
//
//  Created by 이지훈 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public class HomeUseCase: HomeUseCaseProtocol {
    private let homeRepository: HomeRepositoryProtocol
    
    public init(homeRepository: HomeRepositoryProtocol) {
        self.homeRepository = homeRepository
        print("🏠 HomeUseCase 생성")
    }
    
    public func getHomes() async throws -> [Home] {
        return []
    }
    
    public func createHome(title: String, date: Date, description: String?) async throws {
    }
    
    public func deleteHome(id: String) async throws {
    }
    
    public func getUpcomingHomes() async throws -> [Home] {
        return []
    }
} 
