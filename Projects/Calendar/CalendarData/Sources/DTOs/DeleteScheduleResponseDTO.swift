//
//  DeleteScheduleResponseDTO.swift
//  CalendarData
//
//  Created by 이지훈 on 7/9/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public struct DeleteScheduleResponseDTO: Decodable {
    public let result: String
    public let data: String?
    public let error: APIError?
}
