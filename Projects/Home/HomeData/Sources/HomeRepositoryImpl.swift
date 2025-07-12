//
//  HomeRepositoryImpl.swift
//  HomeData
//
//  Created by 이지훈 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import DIContainer
import Foundation
import HomeDomain

public final class HomeRepositoryImpl: HomeRepositoryProtocol {
    public init() {}
    
    public func getHomes() async throws -> [Home] {
        // 빈 배열 반환 - 뷰에서 자체 데이터 사용
        return []
    }
    
    public func createHome(_ home: Home) async throws {
        // 빈 구현
    }
    
    public func deleteHome(id: String) async throws {
        // 빈 구현
    }
} 