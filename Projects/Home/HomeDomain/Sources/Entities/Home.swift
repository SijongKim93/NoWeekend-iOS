//
//  Home.swift
//  HomeDomain
//
//  Created by 이지훈 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

// MARK: - Home Entity  
public struct Home: Codable, Identifiable, Equatable {
    public let id: String
    public let title: String
    public let date: Date
    public let description: String?
    public let category: String?
    public let isCompleted: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: String, 
        title: String, 
        date: Date, 
        description: String? = nil,
        category: String? = nil,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.description = description
        self.category = category
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
