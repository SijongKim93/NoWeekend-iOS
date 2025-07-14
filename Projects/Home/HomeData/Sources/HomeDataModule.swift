//
//  HomeDataModule.swift
//  HomeData
//
//  Created by 김나희 on 7/13/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import DIContainer
import Foundation
import HomeDomain
import NWNetwork

public enum HomeDataModule {
    public static func registerRepositories() {
        print("🏠 HomeData Repository 등록")
        
        DIContainer.shared.container.register(HomeRepositoryProtocol.self) { resolver in
            guard let networkService = resolver.resolve(NWNetworkServiceProtocol.self) else {
                fatalError("❌ NWNetworkServiceProtocol을 resolve할 수 없습니다")
            }
            return HomeRepositoryImpl(networkService: networkService)
        }.inObjectScope(.container)
        
        print("✅ HomeData Repository 등록 완료")
    }
}
