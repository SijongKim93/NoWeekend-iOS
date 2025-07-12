//
//  NetworkService.swift
//  Core
//
//  Created by 이지훈 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Alamofire
import Foundation

public protocol NWNetworkServiceProtocol {
    func get<T: Decodable>(endpoint: String, parameters: [String: Any]?) async throws -> T
    func post<T: Decodable>(endpoint: String, parameters: [String: Any]?) async throws -> T
    func put<T: Decodable>(endpoint: String, parameters: [String: Any]?) async throws -> T
    func delete<T: Decodable>(endpoint: String) async throws -> T
}

public class NWNetworkService: NWNetworkServiceProtocol {
    private let baseURL: String
    private let session: Session
    private var authToken: String?
    
    public init(baseURL: String = Config.baseURL, authToken: String? = nil) {
        self.baseURL = baseURL
        self.authToken = authToken
        
        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        if let token = authToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers
        self.session = Session(configuration: configuration)
    }
    
    public func updateAuthToken(_ token: String?) {
        self.authToken = token
    }
    
    public func get<T: Decodable>(endpoint: String, parameters: [String: Any]?) async throws -> T {
        try await request(endpoint: endpoint, method: .get, parameters: parameters)
    }
    
    public func post<T: Decodable>(endpoint: String, parameters: [String: Any]?) async throws -> T {
        try await request(endpoint: endpoint, method: .post, parameters: parameters)
    }
    
    public func put<T: Decodable>(endpoint: String, parameters: [String: Any]?) async throws -> T {
        try await request(endpoint: endpoint, method: .put, parameters: parameters)
    }
    
    public func delete<T: Decodable>(endpoint: String) async throws -> T {
        try await request(endpoint: endpoint, method: .delete, parameters: nil)
    }
    
    private func getCurrentToken() -> String? {
        if let savedToken = UserDefaults.standard.string(forKey: "access_token"), !savedToken.isEmpty {
            return savedToken
        }
        
        if let staticToken = authToken, !staticToken.isEmpty {
            return staticToken
        }
        
        return Config.tempAccessToken
    }
    
    private func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?
    ) async throws -> T {
        let url = baseURL + endpoint
        
        var headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        // 토큰 우선순위: UserDefaults → 초기화 토큰 → 임시 토큰
        if let token = getCurrentToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
            
            session.request(
                url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: headers
            )
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    // JSON 디코딩
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(T.self, from: data)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                    
                case .failure(let error):
                    print("❌ API 응답 실패: [\(method.rawValue)] \(endpoint)")
                    print("   Error: \(error)")
                    if let statusCode = response.response?.statusCode {
                        print("   Status Code: \(statusCode)")
                    }
                    if let data = response.data, let errorString = String(data: data, encoding: .utf8) {
                        print("   Response: \(errorString)")
                    }
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
