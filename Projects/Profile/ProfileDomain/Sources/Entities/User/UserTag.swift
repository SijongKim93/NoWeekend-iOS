//
//  UserTag.swift
//  ProfileDomain
//
//  Created by SiJongKim on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public struct UserTag: Equatable {
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

public struct UserTagsResponse: Equatable {
    public let selectedBasicTags: [UserTag]
    public let unselectedBasicTags: [UserTag]
    public let selectedCustomTags: [UserTag]
    public let unselectedCustomTags: [UserTag]
    
    public init(
        selectedBasicTags: [UserTag],
        unselectedBasicTags: [UserTag],
        selectedCustomTags: [UserTag],
        unselectedCustomTags: [UserTag]
    ) {
        self.selectedBasicTags = selectedBasicTags
        self.unselectedBasicTags = unselectedBasicTags
        self.selectedCustomTags = selectedCustomTags
        self.unselectedCustomTags = unselectedCustomTags
    }
}

public struct UserTagsUpdateRequest: Equatable {
    public let addScheduleTags: [String]
    public let deleteScheduleTags: [String]
    
    public init(addScheduleTags: [String], deleteScheduleTags: [String]) {
        self.addScheduleTags = addScheduleTags
        self.deleteScheduleTags = deleteScheduleTags
    }
}
