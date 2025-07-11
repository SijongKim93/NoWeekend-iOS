//
//  UserTagDTO.swift
//  ProfileData
//
//  Created by SiJongKim on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public struct UserTagDTO: Codable {
    public let id: String
    public let content: String
    public let userId: String
    public let selected: Bool
    
    public init(id: String, content: String, userId: String, selected: Bool) {
        self.id = id
        self.content = content
        self.userId = userId
        self.selected = selected
    }
}

public struct UserTagsResponseDTO: Codable {
    public let selectedBasicTags: [UserTagDTO]
    public let unselectedBasicTags: [UserTagDTO]
    public let selectedCustomTags: [UserTagDTO]
    public let unselectedCustomTags: [UserTagDTO]
    
    public init(
        selectedBasicTags: [UserTagDTO],
        unselectedBasicTags: [UserTagDTO],
        selectedCustomTags: [UserTagDTO],
        unselectedCustomTags: [UserTagDTO]
    ) {
        self.selectedBasicTags = selectedBasicTags
        self.unselectedBasicTags = unselectedBasicTags
        self.selectedCustomTags = selectedCustomTags
        self.unselectedCustomTags = unselectedCustomTags
    }
}

public struct UserTagsUpdateRequestDTO: Codable {
    public let addScheduleTags: [String]
    public let deleteScheduleTags: [String]
    
    public init(addScheduleTags: [String], deleteScheduleTags: [String]) {
        self.addScheduleTags = addScheduleTags
        self.deleteScheduleTags = deleteScheduleTags
    }
}
