//
//  ProfileDataModule.swift
//  ProfileData
//
//  Created by 이지훈 on 7/3/25.
//

import DIContainer
import Foundation
import NWNetwork
import ProfileDomain

public enum ProfileDataModule {
    public static func registerRepositories() {
        print("👤 ProfileData Repository 등록")
        
        DIContainer.shared.container.register(ProfileNetworkServiceInterface.self) { resolver in
            guard let networkService = resolver.resolve(NWNetworkServiceProtocol.self) else {
                fatalError("❌ NWNetworkServiceProtocol을 resolve할 수 없습니다")
            }
            return ProfileNetworkService(networkService: networkService)
        }.inObjectScope(.container)
        
        DIContainer.shared.container.register(ProfileRepositoryInterface.self) { resolver in
            guard let profileNetworkService = resolver.resolve(ProfileNetworkServiceInterface.self) else {
                fatalError("❌ ProfileNetworkServiceInterface를 resolve할 수 없습니다")
            }
            return ProfileRepository(networkService: profileNetworkService)
        }.inObjectScope(.container)
        
        print("✅ ProfileData Repository 등록 완료")
    }
}
