//
//  OnboardingError.swift
//  OnboardingDomain
//
//  Created by SiJongKim on 7/2/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public enum OnboardingError: Error, LocalizedError, Equatable {
    case nicknameEmpty
    case birthDateEmpty
    case totalDaysMustBePositive
    case hoursExceedLimit
    case tagsInsufficientCount
    case invalidNumber

    case profileSaveFailed(String)
    case leaveSaveFailed(String)
    case tagsSaveFailed(String)
    case networkError(String)
    case networkTimeout
    case networkUnauthorized
    
    case unknown(String)
    case invalidInput
    
    public var errorDescription: String? {
        switch self {
        case .nicknameEmpty:
            return "닉네임을 입력해주세요"
        case .birthDateEmpty:
            return "생년월일을 입력해주세요"
        case .totalDaysMustBePositive:
            return "0보다 큰 숫자를 입력해주세요"
        case .hoursExceedLimit:
            return "8시간 미만으로 입력해주세요"
        case .tagsInsufficientCount:
            return "3개 이상의 태그를 선택해주세요"
        case .invalidNumber:
            return "알 수 없는 숫자입니다."
            
        // MARK: - 네트워크 에러
        case .profileSaveFailed(let message):
            return "프로필 저장 실패: \(message)"
        case .leaveSaveFailed(let message):
            return "연차 정보 저장 실패: \(message)"
        case .tagsSaveFailed(let message):
            return "태그 저장 실패: \(message)"
        case .networkError(let message):
            return "네트워크 오류: \(message)"
        case .networkTimeout:
            return "요청 시간이 초과되었습니다. 다시 시도해주세요"
        case .networkUnauthorized:
            return "인증이 필요합니다. 다시 로그인해주세요"
            
        case .unknown(let message):
            return "알 수 없는 오류: \(message)"
        case .invalidInput:
            return "잘못된 입력입니다"
        }
    }
    
    // MARK: - 재시도 가능 여부
    public var isRetryable: Bool {
        switch self {
        case .networkTimeout, .networkError:
            return true
        case .profileSaveFailed, .leaveSaveFailed, .tagsSaveFailed:
            return true
        case .unknown:
            return true
        default:
            return false
        }
    }
}

// 올바른 생년월일을 입력해 주세요 로 수정해야함

