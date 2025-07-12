//
//  ProfileError.swift
//  ProfileDomain
//
//  Created by SiJongKim on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public enum ProfileError: Error, LocalizedError {
    case noData(source: String)
    case updateFailed(source: String)
    case invalidResponse(source: String)
    case networkError(source: String, underlyingError: Error)
    case mappingError(String)
    case unknownError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .noData(let source):
            return "[\(source)] 데이터를 찾을 수 없습니다"
        case .updateFailed(let source):
            return "[\(source)] 업데이트에 실패했습니다"
        case .invalidResponse(let source):
            return "[\(source)] 잘못된 응답입니다"
        case .networkError(let source, let underlyingError):
            return "[\(source)] 네트워크 오류: \(underlyingError.localizedDescription)"
        case .mappingError(let message):
            return "데이터 변환 오류: \(message)"
        case .unknownError(let error):
            return "알 수 없는 오류: \(error.localizedDescription)"
        }
    }
    
    public var source: String? {
        switch self {
        case .noData(let source),
             .updateFailed(let source),
             .invalidResponse(let source),
             .networkError(let source, _):
            return source
        case .mappingError, .unknownError:
            return nil
        }
    }
}

public enum ProfileNetworkError: Error, LocalizedError {
    case noData(endpoint: String)
    case updateFailed(endpoint: String)
    case invalidResponse(endpoint: String)
    case networkError(endpoint: String, underlyingError: Error)
    
    public var errorDescription: String? {
        switch self {
        case .noData(let endpoint):
            return "[\(endpoint)] 데이터를 찾을 수 없습니다"
        case .updateFailed(let endpoint):
            return "[\(endpoint)] 업데이트에 실패했습니다"
        case .invalidResponse(let endpoint):
            return "[\(endpoint)] 잘못된 응답입니다"
        case .networkError(let endpoint, let underlyingError):
            return "[\(endpoint)] 네트워크 오류: \(underlyingError.localizedDescription)"
        }
    }
    
    public var endpoint: String {
        switch self {
        case .noData(let endpoint),
             .updateFailed(let endpoint),
             .invalidResponse(let endpoint),
             .networkError(let endpoint, _):
            return endpoint
        }
    }
}
