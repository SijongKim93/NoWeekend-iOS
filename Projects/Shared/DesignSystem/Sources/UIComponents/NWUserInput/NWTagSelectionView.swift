//
//  NWTagSelectionView.swift
//  DesignSystem
//
//  Created by SiJongKim on 7/4/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI

// MARK: - Tag Selection Component

public struct NWTagSelectionView: View {
    private let tags: [[String]]
    private let selectedTags: Set<String>
    private let maxSelectionCount: Int?
    private let minSelectionCount: Int?
    private let onTagToggle: (String) -> Void
    private let onSelectionLimitReached: (() -> Void)?
    
    public init(
        tags: [[String]],
        selectedTags: Set<String>,
        maxSelectionCount: Int? = nil,
        minSelectionCount: Int? = nil,
        onTagToggle: @escaping (String) -> Void,
        onSelectionLimitReached: (() -> Void)? = nil
    ) {
        self.tags = tags
        self.selectedTags = selectedTags
        self.maxSelectionCount = maxSelectionCount
        self.minSelectionCount = minSelectionCount
        self.onTagToggle = onTagToggle
        self.onSelectionLimitReached = onSelectionLimitReached
    }
    
    public var body: some View {
        VStack(alignment: .center, spacing: 12) {
            ForEach(0..<tags.count, id: \.self) { rowIndex in
                HStack(spacing: 8) {
                    ForEach(tags[rowIndex], id: \.self) { tag in
                        if !tag.isEmpty {
                            NWTagButton(
                                title: tag,
                                isSelected: selectedTags.contains(tag),
                                isDisabled: isTagDisabled(tag),
                                action: { handleTagToggle(tag) }
                            )
                        } else {
                            Spacer()
                        }
                    }
                    
                    if tags[rowIndex].contains("") {
                        Spacer()
                    }
                }
            }
        }
    }
    
    private func isTagDisabled(_ tag: String) -> Bool {
        guard let maxCount = maxSelectionCount else { return false }
        return !selectedTags.contains(tag) && selectedTags.count >= maxCount
    }
    
    private func handleTagToggle(_ tag: String) {
        if selectedTags.contains(tag) {
            onTagToggle(tag)
        } else {
            if let maxCount = maxSelectionCount, selectedTags.count >= maxCount {
                onSelectionLimitReached?()
            } else {
                onTagToggle(tag)
            }
        }
    }
}

// MARK: - Convenience Extensions
// 고정된 태그값 혹시몰라 커스텀도 가능하도록 구성
public extension NWTagSelectionView {
    static func onboardingTags(
        selectedTags: Set<String>,
        onTagToggle: @escaping (String) -> Void,
        onSelectionLimitReached: (() -> Void)? = nil
    ) -> NWTagSelectionView {
        let defaultTags = [
            ["출근", "퇴근", "회의 참석", "점심 식사 약속"],
            ["헬스장 운동", "카페에서 작업/휴식", "친구 만남"],
            ["술자리", "스터디", "학원 수업", "야근"],
            ["추가 업무", "산책", "반려동물 산책", "집안일"],
            ["은행 업무", "관공서 업무", "독서", "데이트"],
            ["미용실", "드라이브", "나들이", "넷플릭스 시청"],
            ["유튜브 시청", "치지직 시청"]
        ]
        
        return NWTagSelectionView(
            tags: defaultTags,
            selectedTags: selectedTags,
            minSelectionCount: 3,
            onTagToggle: onTagToggle,
            onSelectionLimitReached: onSelectionLimitReached
        )
    }
    
    static func custom(
        tags: [[String]],
        selectedTags: Set<String>,
        maxSelectionCount: Int? = nil,
        minSelectionCount: Int? = nil,
        onTagToggle: @escaping (String) -> Void,
        onSelectionLimitReached: (() -> Void)? = nil
    ) -> NWTagSelectionView {
        return NWTagSelectionView(
            tags: tags,
            selectedTags: selectedTags,
            maxSelectionCount: maxSelectionCount,
            minSelectionCount: minSelectionCount,
            onTagToggle: onTagToggle,
            onSelectionLimitReached: onSelectionLimitReached
        )
    }
}
