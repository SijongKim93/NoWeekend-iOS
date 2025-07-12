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
        print("🔐 LoginData Repository 등록")
        
        DIContainer.shared.container.register(NWNetworkServiceProtocol.self) { _ in
            NWNetworkService()
        }.inObjectScope(.container)
        
        DIContainer.shared.container.register(AuthRepositoryInterface.self) { resolver in
            let networkService = resolver.resolve(NWNetworkServiceProtocol.self)!
            return AuthRepositoryImpl(networkService: networkService)
        }.inObjectScope(.container)
        
        DIContainer.shared.container.register(AppleAuthServiceInterface.self) { _ in
            MainActor.assumeIsolated {
                AppleAuthService()
            }
        }.inObjectScope(.graph)
        
        DIContainer.shared.container.register(GoogleAuthServiceInterface.self) { _ in
            GoogleAuthService()
        }.inObjectScope(.graph)
        
        print("✅ LoginData Repository 등록 완료")
    }
}
