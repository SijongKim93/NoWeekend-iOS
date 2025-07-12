//
//  CalendarView.swift
//  CalendarFeature
//
//  Created by 이지훈 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import CalendarDomain
import DesignSystem
import Utils
import DIContainer
import SwiftUI
import Combine

public struct CalendarView: View {
    @EnvironmentObject private var coordinator: CalendarCoordinator
    @StateObject private var store = CalendarStore()
    @State private var previousSelectedDate: Date?
    
    public init() {}
    
    public var body: some View {
        ZStack {
            mainContent
            overlayContent
            floatingButton
        }
        .sheet(isPresented: Binding(
            get: { store.state.showDatePicker },
            set: { store.send(.dateSelected($0 ? store.state.selectedDate : store.state.selectedDate)) }
        )) {
            DatePickerWithLabelBottomSheet(selectedDate: Binding(
                get: { store.state.selectedDate },
                set: { store.send(.dateSelected($0)) }
            ))
            .onAppear {
                previousSelectedDate = store.state.selectedDate
            }
        }
        .sheet(isPresented: Binding(
            get: { store.state.showTaskEditSheet },
            set: { _ in }
        )) {
            TaskEditBottomSheet(
                onEditAction: {
                    if let index = store.state.selectedTaskIndex {
                        store.send(.taskEditRequested(index))
                    }
                },
                onTomorrowAction: {
                    Task { @MainActor in
                        store.updateState { $0.showTaskEditSheet = false }
                    }
                },
                onDeleteAction: {
                    if let index = store.state.selectedTaskIndex {
                        store.send(.taskDeleteRequested(index))
                    }
                },
                isPresented: Binding(
                    get: { store.state.showTaskEditSheet },
                    set: { newValue in
                        Task { @MainActor in
                            store.updateState { $0.showTaskEditSheet = newValue }
                        }
                    }
                )
            )
        }
        .onReceive(store.effect) { effect in
            handleEffect(effect)
        }
        .task {
            store.send(.viewDidAppear)
        }
    }
}

// MARK: - View Components
private extension CalendarView {
    var mainContent: some View {
        VStack(spacing: 0) {
            CalendarNavigationBar(
                dateText: store.state.currentDateString,
                onDateTapped: {
                    Task { @MainActor in
                        store.updateState { $0.showDatePicker = true }
                    }
                },
                onToggleChanged: { toggle in
                    store.send(.toggleChanged(toggle))
                }
            )
            
            CalendarSection(
                selectedDate: store.state.selectedDate,
                selectedToggle: store.state.selectedToggle,
                onDateTap: { date in
                    store.send(.dateSelected(date))
                },
                calendarCellContent: store.calendarCellContent
            )
            
            contentSection
        }
        .background(.white)
    }
    
    @ViewBuilder
    var contentSection: some View {
        if store.state.selectedToggle == .week {
            if store.state.isLoading {
                VStack {
                    ProgressView("일정을 불러오는 중...")
                        .padding()
                    Spacer()
                }
                .background(.white)
            } else {
                TodoScrollSection(
                    todoItems: Binding(
                        get: { store.state.todoItems },
                        set: { newValue in
                            Task { @MainActor in
                                store.updateState { $0.todoItems = newValue }
                            }
                        }
                    ),
                    selectedTaskIndex: Binding(
                        get: { store.state.selectedTaskIndex },
                        set: { newValue in
                            Task { @MainActor in
                                store.updateState { $0.selectedTaskIndex = newValue }
                            }
                        }
                    ),
                    showTaskEditSheet: Binding(
                        get: { store.state.showTaskEditSheet },
                        set: { newValue in
                            Task { @MainActor in
                                store.updateState { $0.showTaskEditSheet = newValue }
                            }
                        }
                    ),
                    scrollOffset: Binding(
                        get: { store.state.scrollOffset },
                        set: { newValue in
                            store.send(.scrollOffsetChanged(newValue, store.state.isScrolling))
                        }
                    ),
                    isScrolling: Binding(
                        get: { store.state.isScrolling },
                        set: { newValue in
                            store.send(.scrollOffsetChanged(store.state.scrollOffset, newValue))
                        }
                    ),
                    editingTaskIndex: Binding(
                        get: { store.state.editingTaskIndex },
                        set: { newValue in
                            Task { @MainActor in
                                store.updateState { $0.editingTaskIndex = newValue }
                            }
                        }
                    ),
                    onTitleChanged: { index, newTitle in
                        store.send(.taskTitleChanged(index, newTitle))
                    }
                )
                .background(.white)
            }
        } else {
            Spacer()
                .background(.white)
        }
    }
    
    @ViewBuilder
    var overlayContent: some View {
        if store.state.showCategorySelection {
            TaskCategorySelectionView(
                isPresented: Binding(
                    get: { store.state.showCategorySelection },
                    set: { _ in store.send(.categorySelectionToggled) }
                ),
                onCategorySelected: { category in
                    store.send(.categorySelected(category))
                },
                onDirectInputTapped: {
                    store.send(.directInputTapped)
                }
            )
            .zIndex(1)
        }
    }
    
    var floatingButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                FloatingAddButton(
                    isExpanded: store.state.isFloatingButtonExpanded,
                    isShowingCategory: store.state.showCategorySelection,
                    action: {
                        store.send(.categorySelectionToggled)
                    },
                    dismissAction: {
                        store.send(.categorySelectionToggled)
                    }
                )
                .padding(.trailing, 20)
                .padding(.bottom, 33)
            }
        }
        .zIndex(4)
    }
}

// MARK: - Effect Handling
private extension CalendarView {
    func handleEffect(_ effect: CalendarEffect) {
        switch effect {
        case .navigateToTaskCreate(let selectedDate):
            coordinator.push(.taskCreate(selectedDate: selectedDate))
            
        case .navigateToTaskEdit(let todoId, let title, let category, let scheduleId, let selectedDate):
            coordinator.push(.taskEdit(
                todoId: todoId,
                title: title,
                category: category,
                scheduleId: scheduleId,
                selectedDate: selectedDate
            ))
            
        case .showError(_):
            break
        }
    }
}
