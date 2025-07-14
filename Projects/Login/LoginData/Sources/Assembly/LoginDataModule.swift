//
//  LoginDataModule.swift
//  LoginData
//

import DIContainer
import Foundation
import LoginDomain
import NWNetwork

public enum LoginDataModule {
    public static func registerRepositories() {
        
        DIContainer.shared.container.register(NWNetworkServiceProtocol.self) { resolver in
            let tokenManager = resolver.resolve(TokenManagerInterface.self)!
            let savedToken = tokenManager.getAccessToken()
            let authToken = savedToken?.isEmpty == false ? savedToken : Config.tempAccessToken
            
            return NWNetworkService(authToken: authToken)
        }.inObjectScope(.container)
        
        DIContainer.shared.container.register(AuthRepositoryInterface.self) { resolver in
            let networkService = resolver.resolve(NWNetworkServiceProtocol.self)!
            let tokenManager = resolver.resolve(TokenManagerInterface.self)!
            return AuthRepositoryImpl(
                networkService: networkService,
                tokenManager: tokenManager
            )
        }.inObjectScope(.container)
        
        DIContainer.shared.container.register(AppleAuthServiceInterface.self) { _ in
            MainActor.assumeIsolated {
                AppleAuthService()
            }
        }.inObjectScope(.graph)
        
        DIContainer.shared.container.register(GoogleAuthServiceInterface.self) { _ in
            GoogleAuthService()
        }.inObjectScope(.graph)
        
    }
}
