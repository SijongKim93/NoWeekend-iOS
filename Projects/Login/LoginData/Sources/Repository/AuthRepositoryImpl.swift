//
//  AuthRepositoryImpl.swift
//  LoginData
//
//  Created by SiJongKim on 6/11/25.
//

import Foundation
import LoginDomain
import NWNetwork

public final class AuthRepositoryImpl: AuthRepositoryInterface {
    private let networkService: NWNetworkServiceProtocol
    
    public init(networkService: NWNetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    // MARK: - 로그인
    public func loginWithGoogle(authorizationCode: String, name: String?) async throws -> LoginUser {
        print("   - Authorization Code 시작: \(String(authorizationCode.prefix(20)))...")
        print("   - Name: \(name ?? "nil")")
        
        let requestDTO = GoogleLoginRequestDTO(
            authorizationCode: authorizationCode,
            name: name
        )
        
        do {
            let parameters = try requestDTO.asDictionary()
            parameters.forEach { key, value in
                print("   - \(key): \(value)")
            }
            
            let endpoint = "/login/GOOGLE"
            
            let apiDTO: ApiResponseGoogleLoginDTO = try await networkService.post(
                endpoint: endpoint,
                parameters: parameters
            )
            
            print("📥 서버 응답:")
            print("   - result: \(apiDTO.result)")
            print("   - data.email: \(apiDTO.data.email)")
            print("   - data.exists: \(apiDTO.data.exists)")
            
            guard apiDTO.result == "SUCCESS" else {
                let errorMessage = apiDTO.error?.message ?? "Server Error"
                let errorCode = apiDTO.error?.code ?? "UNKNOWN"
                print("❌ 서버 오류:")
                print("   - Code: \(errorCode)")
                print("   - Message: \(errorMessage)")
                throw mapToLoginError(errorMessage)
            }
            
            print("✅ Google 로그인 API 성공")
            return apiDTO.data.toDomain()
            
        } catch let error as NetworkError {
            print("❌ 네트워크 에러 발생:")
            print("   - Type: \(type(of: error))")
            print("   - Description: \(error.localizedDescription)")
            throw mapNetworkErrorToLoginError(error)
            
        } catch let decodingError as DecodingError {
            print("❌ 디코딩 에러 발생:")
            handleDecodingError(decodingError)
            throw LoginError.authenticationFailed(decodingError)
            
        } catch {
            print("❌ 예상치 못한 에러:")
            print("   - Type: \(type(of: error))")
            print("   - Description: \(error.localizedDescription)")
            throw mapNetworkErrorToLoginError(error)
        }
    }
    
    public func loginWithApple(authorizationCode: String, name: String?) async throws -> LoginUser {
        print("📤 Apple 로그인 API 호출")
        print("   - Authorization Code 길이: \(authorizationCode.count)자")
        print("   - Name: \(name ?? "nil")")
        
        let requestDTO = AppleLoginRequestDTO(
            authorizationCode: authorizationCode,
            name: name
        )
        
        do {
            let parameters = try requestDTO.asDictionary()
            let endpoint = "/login/APPLE"
            
            let apiDTO: ApiResponseAppleLoginDTO = try await networkService.post(
                endpoint: endpoint,
                parameters: parameters
            )
            
            guard apiDTO.result == "SUCCESS" else {
                let errorMessage = apiDTO.error?.message ?? "Server Error"
                print("❌ Apple 로그인 서버 오류: \(errorMessage)")
                throw mapToLoginError(errorMessage)
            }
            
            print("✅ Apple 로그인 API 성공")
            return apiDTO.data.toDomain()
            
        } catch {
            print("❌ Apple 로그인 실패: \(error)")
            throw mapNetworkErrorToLoginError(error)
        }
    }
    
    // MARK: - Apple 회원탈퇴
    public func withdrawAppleAccount(identityToken: String) async throws {
        print("📤 Apple 회원탈퇴 API 호출")
        
        let requestDTO = AppleWithdrawalRequestDTO(identityToken: identityToken)
        let parameters = try requestDTO.asDictionary()
        let endpoint = "/withdrawal/APPLE"
        
        do {
            let apiDTO: ApiResponseWithdrawalDTO = try await networkService.post(
                endpoint: endpoint,
                parameters: parameters
            )
            
            guard apiDTO.result == "SUCCESS" else {
                let errorMessage = apiDTO.error?.message ?? "Server Error"
                throw LoginError.withdrawalFailed(
                    NSError(domain: "WithdrawalError", code: 500,
                           userInfo: [NSLocalizedDescriptionKey: errorMessage])
                )
            }
            
            print("✅ Apple 회원탈퇴 API 성공")
            
        } catch {
            throw mapNetworkErrorToWithdrawalError(error)
        }
    }
    
    // MARK: - Error Mapping & Debugging
    
    private func handleDecodingError(_ error: DecodingError) {
        switch error {
        case .typeMismatch(let type, let context):
            print("   - Type Mismatch: 예상 타입 \(type), 경로: \(context.codingPath)")
            print("   - Context: \(context.debugDescription)")
            
        case .valueNotFound(let type, let context):
            print("   - Value Not Found: \(type), 경로: \(context.codingPath)")
            print("   - Context: \(context.debugDescription)")
            
        case .keyNotFound(let key, let context):
            print("   - Key Not Found: \(key), 경로: \(context.codingPath)")
            print("   - Context: \(context.debugDescription)")
            
        case .dataCorrupted(let context):
            print("   - Data Corrupted: 경로: \(context.codingPath)")
            print("   - Context: \(context.debugDescription)")
            
        @unknown default:
            print("   - Unknown Decoding Error: \(error)")
        }
    }
    
    private func mapNetworkErrorToLoginError(_ error: Error) -> LoginError {
        print("🔄 네트워크 에러 매핑:")
        print("   - Original Error: \(type(of: error))")
        
        if let networkError = error as? NetworkError {
            switch networkError {
            case .serverError(let message):
                print("   - Server Error: \(message)")
                if message.contains("401") || message.contains("Unauthorized") {
                    return .registrationRequired(networkError)
                } else {
                    return .authenticationFailed(networkError)
                }
            case .decodingError:
                print("   - Decoding Error")
                return .authenticationFailed(networkError)
            case .notImplemented(let message):
                print("   - Not Implemented: \(message)")
                return .authenticationFailed(networkError)
            case .unknown(let underlyingError):
                print("   - Unknown Error: \(underlyingError)")
                return .authenticationFailed(networkError)
            @unknown default:
                print("   - Unknown Network Error")
                return .authenticationFailed(networkError)
            }
        } else {
            print("   - Non-Network Error: \(error)")
            return .authenticationFailed(error)
        }
    }
    
    private func mapNetworkErrorToWithdrawalError(_ error: Error) -> LoginError {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .serverError(let message):
                return .withdrawalFailed(
                    NSError(domain: "WithdrawalError", code: 500,
                           userInfo: [NSLocalizedDescriptionKey: message])
                )
            case .decodingError, .notImplemented, .unknown:
                return .withdrawalFailed(networkError)
            @unknown default:
                return .withdrawalFailed(networkError)
            }
        } else {
            return .withdrawalFailed(error)
        }
    }
    
    private func mapToLoginError(_ message: String) -> LoginError {
        if message.contains("401") || message.contains("Unauthorized") {
            return .registrationRequired(
                NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: message])
            )
        } else {
            return .authenticationFailed(
                NSError(domain: "AuthError", code: 500, userInfo: [NSLocalizedDescriptionKey: message])
            )
        }
    }
}

// MARK: - Encodable Extension
extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = json as? [String: Any] else {
            throw NSError(domain: "Encoding", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert to dictionary"])
        }
        return dict
    }
}
