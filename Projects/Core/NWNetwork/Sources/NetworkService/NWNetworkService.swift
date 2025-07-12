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
    func patch<T: Decodable>(endpoint: String, parameters: [String: Any]?) async throws -> T
    func put<T: Decodable>(endpoint: String, parameters: [String: Any]?) async throws -> T
    func delete<T: Decodable>(endpoint: String) async throws -> T
}

public class NWNetworkService: NWNetworkServiceProtocol {
    private let baseURL: String
    private let session: Session
    
    public init(baseURL: String = Config.baseURL, authToken: String? = nil) {
        self.baseURL = baseURL
        
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
        try await request(endpoint: endpoint, method: .patch, parameters: parameters)
    }
    
    // MARK: - Main Request Method
    
    private func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?
    ) async throws -> T {
        let url = baseURL + endpoint
        let startTime = Date()
        
        logRequestStart(url: url, method: method, expectedType: T.self, parameters: parameters)
        
        return try await performRequest(url: url, method: method, parameters: parameters, startTime: startTime)
    }
    
    // MARK: - Request Execution
    
    private func performRequest<T: Decodable>(
        url: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        startTime: Date
    ) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default)
                .validate()
                .responseData { response in
                    self.handleResponse(response, startTime: startTime, continuation: continuation)
                }
        }
    }
    
    // MARK: - Response Handling
    
    private func handleResponse<T: Decodable>(
        _ response: AFDataResponse<Data>,
        startTime: Date,
        continuation: CheckedContinuation<T, Error>
    ) {
        let duration = Date().timeIntervalSince(startTime)
        logResponseInfo(response, duration: duration)
        
        switch response.result {
        case .success(let data):
            handleSuccessResponse(data: data, continuation: continuation)
        case .failure(let error):
            handleErrorResponse(error: error, responseData: response.data, continuation: continuation)
        }
    }
    
    private func handleSuccessResponse<T: Decodable>(
        data: Data,
        continuation: CheckedContinuation<T, Error>
    ) {
        do {
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(T.self, from: data)
            print("✅ 디코딩 성공")
            continuation.resume(returning: decodedResponse)
        } catch {
            logDecodingFailure(error)
            continuation.resume(throwing: NetworkError.decodingError)
        }
    }
    
    private func handleErrorResponse<T>(
        error: AFError,
        responseData: Data?,
        continuation: CheckedContinuation<T, Error>
    ) {
        print("❌ 네트워크 요청 실패:")
        print("   - Error Type: \(type(of: error))")
        print("   - Error Description: \(error.localizedDescription)")
        
        let networkError = mapAlamofireError(error, responseData: responseData)
        continuation.resume(throwing: networkError)
    }
    
    // MARK: - Logging Methods
    
    private func logRequestStart<T>(
        url: String,
        method: HTTPMethod,
        expectedType: T.Type,
        parameters: [String: Any]?
    ) {
        print("🌐 네트워크 요청 시작:")
        print("   - URL: \(url)")
        print("   - Method: \(method.rawValue)")
        print("   - Expected Response Type: \(expectedType)")
        
        if let params = parameters {
            logRequestParameters(params)
        }
    }
    
    private func logRequestParameters(_ parameters: [String: Any]) {
        print("   - Parameters:")
        parameters.forEach { key, value in
            if shouldMaskParameter(key) {
                print("     - \(key): \(String(describing: value).prefix(20))...")
            } else {
                print("     - \(key): \(value)")
            }
        }
    }
    
    private func shouldMaskParameter(_ key: String) -> Bool {
        let sensitiveKeys = ["token", "code", "password", "secret"]
        return sensitiveKeys.contains { key.lowercased().contains($0) }
    }
    
    private func logResponseInfo(_ response: AFDataResponse<Data>, duration: TimeInterval) {
        print("🌐 네트워크 응답 완료 (소요시간: \(String(format: "%.2f", duration))초):")
        
        if let httpResponse = response.response {
            logHTTPStatus(httpResponse)
        }
        
        if let data = response.data {
            logResponseData(data)
        }
    }
    
    private func logHTTPStatus(_ httpResponse: HTTPURLResponse) {
        print("   - HTTP Status: \(httpResponse.statusCode)")
        print("   - Headers:")
        httpResponse.allHeaderFields.forEach { key, value in
            print("     - \(key): \(value)")
        }
    }
    
    private func logResponseData(_ data: Data) {
        print("   - Response Size: \(data.count) bytes")
        
        if let jsonString = prettyPrintJSON(data) {
            print("   - Response JSON:")
            print("     \(jsonString)")
        } else {
            logRawResponseData(data)
        }
    }
    
    private func logRawResponseData(_ data: Data) {
        print("   - Response Data (첫 500자):")
        if let string = String(data: data, encoding: .utf8) {
            print("     \(string.prefix(500))")
        }
    }
    
    private func logDecodingFailure(_ error: Error) {
        print("❌ 디코딩 실패:")
        print("   - Error: \(error)")
        if let decodingError = error as? DecodingError {
            logDecodingError(decodingError)
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
            logTypeMismatchError(type: type, context: context)
        case .valueNotFound(let type, let context):
            logValueNotFoundError(type: type, context: context)
        case .keyNotFound(let key, let context):
            logKeyNotFoundError(key: key, context: context)
        case .dataCorrupted(let context):
            logDataCorruptedError(context: context)
        @unknown default:
            print("     - Unknown Decoding Error: \(error)")
        }
    }
    
    private func logTypeMismatchError(type: Any.Type, context: DecodingError.Context) {
        print("     - Type Mismatch: 예상 \(type)")
        print("     - Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
        print("     - Description: \(context.debugDescription)")
    }
    
    private func logValueNotFoundError(type: Any.Type, context: DecodingError.Context) {
        print("     - Value Not Found: \(type)")
        print("     - Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
        print("     - Description: \(context.debugDescription)")
    }
    
    private func logKeyNotFoundError(key: CodingKey, context: DecodingError.Context) {
        print("     - Key Not Found: \(key.stringValue)")
        print("     - Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
        print("     - Available Keys: \(context.debugDescription)")
    }
    
    private func logDataCorruptedError(context: DecodingError.Context) {
        print("     - Data Corrupted")
        print("     - Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
        print("     - Description: \(context.debugDescription)")
    }
}
