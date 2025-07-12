//
//  ProfileTagsView.swift
//  ProfileFeature
//
//  Created by SiJongKim on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI
import DesignSystem
import DIContainer
import Combine


struct ProfileTagsView: View {
    @EnvironmentObject var coordinator: ProfileCoordinator
    @ObservedObject private var tagsStore: TagsStore
    
    @State private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.tagsStore = DIContainer.shared.resolve(TagsStore.self)
    }
    
    var body: some View {
        VStack {
            CustomNavigationBar(
                type: .backWithLabelAndSave("자주하는 일정"),
                onBackTapped: {
                    coordinator.pop()
                },
                onSaveTapped: {
                    
                }
            )
            .padding(.bottom, 48)
            
            VStack {
                NWUserInputView(
                    title: "자주하는 일정을 알려주세요",
                    subtitle: "할일 등록을 AI에게 추천받을 수 있어요"
                ) {
                    VStack {
//                        NWTagSelectionView.onboardingTags(
//                            selectedTags: store.state.selectedTags,
//                            onTagToggle: { tag in
//                                store.send(.toggleTag(tag))
//                            }
//                        )
                    }
                    .padding(.top, 40)
                }
                
                Spacer()
                
//                NWButton(
//                    title: "",
//                    variant: .black,
//                    isEnabled: store.state. && !store.state.isLoading
//                ) {
//                    
//                }
            }
        }
        
    }
}
