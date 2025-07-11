//
//  ProfileFeatureAssembly.swift
//  ProfileFeature
//
//  Created by 이지훈 on 7/4/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import DIContainer
import Foundation
import ProfileDomain
import ProfileData
import NWNetwork
import Swinject

public struct ProfileFeatureAssembly: Assembly {
    public init() {}
    
    public func assemble(container: Container) {
        print("🔧 ProfileFeatureAssembly 등록 시작")
        
        // MARK: - Base Network Service
        container.register(NWNetworkServiceProtocol.self) { resolver in
            let token = UserDefaults.standard.string(forKey: "access_token")
            return NWNetworkService(authToken: token)
        }
        .inObjectScope(.container)
        
        // MARK: - Profile Network Service
        container.register(ProfileNetworkServiceInterface.self) { resolver in
            let baseNetworkService = resolver.resolve(NWNetworkServiceProtocol.self)!
            return ProfileNetworkService(networkService: baseNetworkService)
        }.inObjectScope(.container)
        
        // MARK: - Profile Repository
        container.register(ProfileRepositoryInterface.self) { resolver in
            let profileNetworkService = resolver.resolve(ProfileNetworkServiceInterface.self)!
            return ProfileRepository(networkService: profileNetworkService)
        }.inObjectScope(.container)
        
        // MARK: - Use Cases
        container.register(GetUserProfileUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(ProfileRepositoryInterface.self)!
            return GetUserProfileUseCase(repository: repository)
        }.inObjectScope(.graph)
        
        container.register(UpdateUserProfileUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(ProfileRepositoryInterface.self)!
            return UpdateUserProfileUseCase(repository: repository)
        }.inObjectScope(.graph)
        
        container.register(GetUserTagsUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(ProfileRepositoryInterface.self)!
            return GetUserTagsUseCase(repository: repository)
        }.inObjectScope(.graph)
        
        container.register(UpdateUserTagsUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(ProfileRepositoryInterface.self)!
            return UpdateUserTagsUseCase(repository: repository)
        }.inObjectScope(.graph)
        
        container.register(UpdateVacationLeaveUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(ProfileRepositoryInterface.self)!
            return UpdateVacationLeaveUseCase(repository: repository)
        }.inObjectScope(.graph)
        
        // MARK: - Stores
        container.register(ProfileStore.self) { resolver in
            let getUserProfileUseCase = resolver.resolve(GetUserProfileUseCaseProtocol.self)!
            let updateUserProfileUseCase = resolver.resolve(UpdateUserProfileUseCaseProtocol.self)!
            
            return ProfileStore(
                getUserProfileUseCase: getUserProfileUseCase,
                updateUserProfileUseCase: updateUserProfileUseCase
            )
        }.inObjectScope(.graph)
    
    }
}
