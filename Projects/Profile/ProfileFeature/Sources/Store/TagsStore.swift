//
//  TagsStore.swift
//  ProfileFeature
//
//  Created by 김시종 on 7/12/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Combine
import Foundation
import ProfileDomain

public final class TagsStore: ObservableObject {
    
    @Published public private(set) var state = TagsState()
    
    private let effectSubject = PassthroughSubject<TagsEffect, Never>()
    public var effect: AnyPublisher<TagsEffect, Never> {
        effectSubject.eraseToAnyPublisher()
    }
    
    private let getUserTagsUseCase: GetUserTagsUseCaseProtocol
    private let updateUserTagsUseCase: UpdateUserTagsUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        getUserTagsUseCase: GetUserTagsUseCaseProtocol,
        updateUserTagsUseCase: UpdateUserTagsUseCaseProtocol
    ) {
        self.getUserTagsUseCase = getUserTagsUseCase
        self.updateUserTagsUseCase = updateUserTagsUseCase
    }
    
    public func send(_ action: TagsAction) {
        switch action {
        case .loadUserTags:
            handleLoadUserTags()
            
        case .userTagsLoaded(let response):
            handleUserTagsLoaded(response)
            
        case .loadUserTagsFailed(let error):
            handleLoadUserTagsFailed(error)
            
        case .toggleBasicTag(let tag):
            handleToggleBasicTag(tag)
            
        case .toggleCustomTag(let tag):
            handleToggleCustomTag(tag)
            
        case .addCustomTag(let tag):
            handleAddCustomTag(tag)
            
        case .removeCustomTag(let tag):
            handleRemoveCustomTag(tag)
            
        case .saveTags:
            handleSaveTags()
            
        case .tagsSaved(let response):
            handleTagsSaved(response)
            
        case .tagsSaveFailed(let error):
            handleTagsSaveFailed(error)
            
        case .clearErrors:
            handleClearErrors()
            
        case .resetState:
            handleResetState()
        }
    }
    
    // MARK: - Action Handlers
    
    private func handleLoadUserTags() {
        state.isLoading = true
        state.generalError = nil
        
        Task { @MainActor in
            do {
                let response = try await getUserTagsUseCase.execute()
                send(.userTagsLoaded(response))
            } catch {
                send(.loadUserTagsFailed(error))
            }
        }
    }
    
    private func handleUserTagsLoaded(_ response: UserTagsResponse) {
        state.isLoading = false
        state.userTagsResponse = response
        
        state.allBasicTags = response.selectedBasicTags + response.unselectedBasicTags
        state.allCustomTags = response.selectedCustomTags + response.unselectedCustomTags
        
        state.selectedBasicTags = Set(response.selectedBasicTags.map { $0.content })
        state.selectedCustomTags = Set(response.selectedCustomTags.map { $0.content })
    }
    
    private func handleLoadUserTagsFailed(_ error: Error) {
        state.isLoading = false
        state.generalError = error.localizedDescription
        effectSubject.send(.showErrorMessage("태그 정보를 불러오는데 실패했습니다"))
    }
    
    private func handleToggleBasicTag(_ tag: String) {
        if state.selectedBasicTags.contains(tag) {
            state.selectedBasicTags.remove(tag)
        } else {
            state.selectedBasicTags.insert(tag)
        }
    }
    
    private func handleToggleCustomTag(_ tag: String) {
        if state.selectedCustomTags.contains(tag) {
            state.selectedCustomTags.remove(tag)
        } else {
            state.selectedCustomTags.insert(tag)
        }
    }
    
    private func handleAddCustomTag(_ tag: String) {
        let trimmedTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTag.isEmpty && !state.selectedCustomTags.contains(trimmedTag) else { return }
        
        state.selectedCustomTags.insert(trimmedTag)
    }
    
    private func handleRemoveCustomTag(_ tag: String) {
        state.selectedCustomTags.remove(tag)
    }
    
    private func handleSaveTags() {
        guard state.isFormValid else { return }
        
        state.isSaving = true
        state.generalError = nil
        
        // 변경사항 계산
        guard let originalResponse = state.userTagsResponse else { return }
        
        let originalBasicTags = Set(originalResponse.selectedBasicTags.map { $0.content })
        let originalCustomTags = Set(originalResponse.selectedCustomTags.map { $0.content })
        
        // 추가할 태그들
        let addBasicTags = state.selectedBasicTags.subtracting(originalBasicTags)
        let addCustomTags = state.selectedCustomTags.subtracting(originalCustomTags)
        let addTags = Array(addBasicTags) + Array(addCustomTags)
        
        // 삭제할 태그들
        let deleteBasicTags = originalBasicTags.subtracting(state.selectedBasicTags)
        let deleteCustomTags = originalCustomTags.subtracting(state.selectedCustomTags)
        let deleteTags = Array(deleteBasicTags) + Array(deleteCustomTags)
        
        let request = UserTagsUpdateRequest(
            addScheduleTags: addTags,
            deleteScheduleTags: deleteTags
        )
        
        Task { @MainActor in
            do {
                let response = try await updateUserTagsUseCase.execute(request)
                send(.tagsSaved(response))
            } catch {
                send(.tagsSaveFailed(error))
            }
        }
    }
    
    private func handleTagsSaved(_ response: UserTagsResponse) {
        state.isSaving = false
        state.saveSuccess = true
        state.userTagsResponse = response
        
        state.allBasicTags = response.selectedBasicTags + response.unselectedBasicTags
        state.allCustomTags = response.selectedCustomTags + response.unselectedCustomTags
        state.selectedBasicTags = Set(response.selectedBasicTags.map { $0.content })
        state.selectedCustomTags = Set(response.selectedCustomTags.map { $0.content })
        
        effectSubject.send(.showSuccessMessage("태그가 성공적으로 저장되었습니다"))
        effectSubject.send(.navigateBack)
    }
    
    private func handleTagsSaveFailed(_ error: Error) {
        state.isSaving = false
        
        if let validationError = error as? ProfileValidationError {
            state.generalError = validationError.localizedDescription
        } else {
            state.generalError = error.localizedDescription
        }
        
        effectSubject.send(.showErrorMessage("태그 저장에 실패했습니다"))
    }
    
    private func handleClearErrors() {
        state.generalError = nil
    }
    
    private func handleResetState() {
        state = TagsState()
    }
}

// MARK: - 5. TagsStore 편의 메서드

public extension TagsStore {
    func loadInitialData() {
        send(.loadUserTags)
    }
    
    func toggleBasicTag(_ tag: String) {
        send(.toggleBasicTag(tag))
    }
    
    func toggleCustomTag(_ tag: String) {
        send(.toggleCustomTag(tag))
    }
    
    func addCustomTag(_ tag: String) {
        send(.addCustomTag(tag))
    }
    
    func removeCustomTag(_ tag: String) {
        send(.removeCustomTag(tag))
    }
    
    func saveTags() {
        send(.saveTags)
    }
    
    func clearErrors() {
        send(.clearErrors)
    }
    
    func resetState() {
        send(.resetState)
    }
    
    // UI에서 사용할 편의 프로퍼티들
    var allSelectedTags: [String] {
        Array(state.selectedBasicTags) + Array(state.selectedCustomTags)
    }
    
    var availableBasicTags: [String] {
        state.allBasicTags.map { $0.content }
    }
    
    var availableCustomTags: [String] {
        state.allCustomTags.map { $0.content }
    }
    
    func isTagSelected(_ tag: String) -> Bool {
        state.selectedBasicTags.contains(tag) || state.selectedCustomTags.contains(tag)
    }
}
