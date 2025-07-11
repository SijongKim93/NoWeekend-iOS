//
//  ProfileDataModule.swift
//  ProfileData
//
//  Created by 이지훈 on 7/3/25.
//

import DIContainer
import Foundation
import ProfileDomain
import NWNetwork

public enum ProfileDataModule {
    public static func registerRepositories() {
        print("👤 ProfileData Repository 등록")
        
        DIContainer.shared.container.register(ProfileRepositoryInterface.self) { resolver in
            let networkService = resolver.resolve(NWNetworkServiceProtocol.self)!
            return ProfileRepository(networkService: networkService as! ProfileNetworkServiceInterface)
        }.inObjectScope(.container)
        
        print("✅ ProfileData Repository 등록 완료")
    }
}
