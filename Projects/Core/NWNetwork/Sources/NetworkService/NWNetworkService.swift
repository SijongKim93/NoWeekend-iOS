//
//  NetworkService.swift
//  Core
//
//  Created by 이지훈 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Alamofire
import Foundation
import DIContainer

public protocol NWNetworkServiceProtocol {
    func get<T: Decodable>(endpoint: String, parameters: [String: Any]?) async throws -> T
    func post<T: Decodable>(endpoint: String, parameters: [String: Any]?) async throws -> T
    func patch<T: Decodable>(endpoint: String, parameters: [String: Any]?) async throws -> T
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
    
    public func patch<T: Decodable>(endpoint: String, parameters: [String: Any]?) async throws -> T {
        return try await request(endpoint: endpoint, method: .patch, parameters: parameters)
    }
    
    private func getCurrentToken() -> String? {
        if let runtimeToken = authToken, !runtimeToken.isEmpty {
            return runtimeToken
        }
        
        do {
            let tokenManager = DIContainer.shared.resolve(TokenManagerInterface.self)
            if let token = tokenManager.getAccessToken(), !token.isEmpty {
                return token
            }
        }
        
        if let savedToken = UserDefaults.standard.string(forKey: "access_token"), !savedToken.isEmpty {
            return savedToken
        }
        
        return Config.tempAccessToken
    }
    
    
    // MARK: - Main Request Method
    
    private func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?
    ) async throws -> T {
        let url = baseURL + endpoint
        let startTime = Date()
        
        print("🌐 네트워크 요청 시작:")
        print("   - URL: \(url)")
        print("   - Method: \(method.rawValue)")
        print("   - Expected Response Type: \(T.self)")
        
        if let params = parameters {
            print("   - Parameters:")
            params.forEach { key, value in
                if key.lowercased().contains("token") || key.lowercased().contains("code") {
                    print("     - \(key): \(String(describing: value).prefix(20))...")
                } else {
                    print("     - \(key): \(value)")
                }
            }
        }
        
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
                let endTime = Date()
                let duration = endTime.timeIntervalSince(startTime)
                
                print("🌐 네트워크 응답 완료 (소요시간: \(String(format: "%.2f", duration))초):")
                
                // HTTP 상태 코드 로깅
                if let httpResponse = response.response {
                    print("   - HTTP Status: \(httpResponse.statusCode)")
                    print("   - Headers:")
                    httpResponse.allHeaderFields.forEach { key, value in
                        print("     - \(key): \(value)")
                    }
                }
                
                // 응답 데이터 로깅
                if let data = response.data {
                    print("   - Response Size: \(data.count) bytes")
                    
                    // JSON 응답을 읽기 쉽게 출력
                    if let jsonString = self.prettyPrintJSON(data) {
                        print("   - Response JSON:")
                        print("     \(jsonString)")
                    } else {
                        print("   - Response Data (첫 500자):")
                        if let string = String(data: data, encoding: .utf8) {
                            print("     \(string.prefix(500))")
                        }
                    }
                }
                
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let decodedResponse = try decoder.decode(T.self, from: data)
                        print("✅ 디코딩 성공")
                        continuation.resume(returning: decodedResponse)
                    } catch {
                        print("❌ 디코딩 실패:")
                        print("   - Error: \(error)")
                        if let decodingError = error as? DecodingError {
                            self.logDecodingError(decodingError)
                        }
                        continuation.resume(throwing: NetworkError.decodingError)
                    }
                    
                case .failure(let error):
                    print("❌ 네트워크 요청 실패:")
                    print("   - Error Type: \(type(of: error))")
                    print("   - Error Description: \(error.localizedDescription)")
                    
                    let networkError = self.mapAlamofireError(error, responseData: response.data)
                    continuation.resume(throwing: networkError)
                }
            }
        }
    }
    
    // MARK: - Error Mapping
    
    private func mapAlamofireError(_ error: AFError, responseData: Data?) -> NetworkError {
        switch error {
        case .responseValidationFailed(let reason):
            return handleValidationFailure(reason, responseData: responseData)
        case .responseSerializationFailed(let reason):
            return handleSerializationFailure(reason)
        case .sessionTaskFailed(let underlyingError):
            return handleSessionTaskFailure(underlyingError)
        default:
            return .unknown(error)
        }
    }
    
    private func handleValidationFailure(
        _ reason: AFError.ResponseValidationFailureReason,
        responseData: Data?
    ) -> NetworkError {
        switch reason {
        case .unacceptableStatusCode(let statusCode):
            let serverMessage = extractServerErrorMessage(from: responseData, statusCode: statusCode)
            return .serverError("HTTP \(statusCode): \(serverMessage)")
        case .unacceptableContentType(let acceptableTypes, let responseType):
            return .serverError("잘못된 Content-Type: 예상 \(acceptableTypes), 실제 \(responseType)")
        default:
            return .serverError("응답 검증 실패")
        }
    }
    
    private func handleSerializationFailure(_ reason: AFError.ResponseSerializationFailureReason) -> NetworkError {
        switch reason {
        case .decodingFailed:
            return .decodingError
        default:
            return .decodingError
        }
    }
    
    private func handleSessionTaskFailure(_ underlyingError: Error) -> NetworkError {
        guard let urlError = underlyingError as? URLError else {
            return .unknown(underlyingError)
        }
        
        switch urlError.code {
        case .notConnectedToInternet:
            return .serverError("인터넷 연결을 확인해주세요")
        case .timedOut:
            return .serverError("요청 시간이 초과되었습니다")
        case .cannotFindHost:
            return .serverError("서버를 찾을 수 없습니다")
        default:
            return .serverError("네트워크 오류: \(urlError.localizedDescription)")
        }
    }
    
    private func extractServerErrorMessage(from data: Data?, statusCode: Int) -> String {
        guard let data = data else {
            return "서버 오류 (상태 코드: \(statusCode))"
        }
        
        if let errorMessage = parseJSONErrorMessage(data) {
            return errorMessage
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            return responseString.prefix(200).description
        }
        
        return "알 수 없는 서버 오류 (상태 코드: \(statusCode))"
    }
    
    private func parseJSONErrorMessage(_ data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        // 일반적인 에러 응답 구조들 확인
        if let error = json["error"] as? [String: Any],
           let message = error["message"] as? String {
            return message
        }
        
        if let message = json["message"] as? String {
            return message
        }
        
        if let detail = json["detail"] as? String {
            return detail
        }
        
        return nil
    }
    
    // MARK: - Debugging Helpers
    
    private func prettyPrintJSON(_ data: Data) -> String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return nil
        }
        return prettyString
    }
    
    private func logDecodingError(_ error: DecodingError) {
        switch error {
        case .typeMismatch(let type, let context):
            print("     - Type Mismatch: 예상 \(type)")
            print("     - Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            print("     - Description: \(context.debugDescription)")
            
        case .valueNotFound(let type, let context):
            print("     - Value Not Found: \(type)")
            print("     - Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            print("     - Description: \(context.debugDescription)")
            
        case .keyNotFound(let key, let context):
            print("     - Key Not Found: \(key.stringValue)")
            print("     - Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            print("     - Available Keys: \(context.debugDescription)")
            
        case .dataCorrupted(let context):
            print("     - Data Corrupted")
            print("     - Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            print("     - Description: \(context.debugDescription)")
            
        @unknown default:
            print("     - Unknown Decoding Error: \(error)")
        }
    }
}
