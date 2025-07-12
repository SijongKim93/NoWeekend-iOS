//
//  AIRecommendation.swift
//  ProfileDomain
//
//  Created by 김시종 on 7/12/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public struct AIRecommendationResponse: Codable {
    public let reuslt: String
    public let data: AIRecommendationData?
    public let error: String?
    
    public init(reuslt: String, data: AIRecommendationData?, error: String?) {
        self.reuslt = reuslt
        self.data = data
        self.error = error
    }
}

public struct AIRecommendationData: Codable {
    public let firstRecommendTag: RecommendTag
    public let secondRecommendTag: RecommendTag
    public let thirdRecommendTag: RecommendTag
    
    public init(firstRecommendTag: RecommendTag, secondRecommendTag: RecommendTag, thirdRecommendTag: RecommendTag) {
        self.firstRecommendTag = firstRecommendTag
        self.secondRecommendTag = secondRecommendTag
        self.thirdRecommendTag = thirdRecommendTag
    }
    
    public var recommendedTags: [String] {
        return [
            firstRecommendTag.content,
            secondRecommendTag.content,
            thirdRecommendTag.content
        ]
    }
}

public struct RecommendTag: Codable {
    public let content: String
    
    public init(content: String) {
        self.content = content
    }
}
