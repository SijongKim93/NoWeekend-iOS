//
//  CalendarView.swift
//  CalendarFeature
//
//  Created by 이지훈 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import CalendarDomain
import Combine
import DesignSystem
import DIContainer
import SwiftUI
import Utils

public struct CalendarView: View {
    @EnvironmentObject private var coordinator: CalendarCoordinator
    @StateObject private var store = CalendarStore()
    
    @State private var showDatePickerSheet = false
    @State private var showTaskEditSheet = false
    @State private var datePickerSelectedDate = Date()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            mainContent
            overlayContent
            floatingButton
        }
        .sheet(isPresented: $showDatePickerSheet) {
            DatePickerWithLabelBottomSheet(selectedDate: $datePickerSelectedDate)
                .onAppear {
                    print("🔵 DatePicker sheet appeared")
                    datePickerSelectedDate = store.state.selectedDate
                }
                .onDisappear {
                    print("🔵 DatePicker sheet disappeared")
                    if datePickerSelectedDate != store.state.selectedDate {
                        store.send(.dateSelected(datePickerSelectedDate))
                    }
                }
        }
        .sheet(isPresented: $showTaskEditSheet) {
            TaskEditBottomSheet(
                onEditAction: {
                    print("🟡 Edit action triggered")
                    if let index = store.state.selectedTaskIndex {
                        store.send(.taskEditRequested(index))
                    }
                    showTaskEditSheet = false
                },
                onTomorrowAction: {
                    print("🟡 Tomorrow action triggered")
                    if let index = store.state.selectedTaskIndex {
                        store.send(.taskTomorrowRequested(index))
                    }
                    showTaskEditSheet = false
                },
                onDeleteAction: {
                    print("🟡 Delete action triggered")
                    if let index = store.state.selectedTaskIndex {
                        store.send(.taskDeleteRequested(index))
                    }
                    showTaskEditSheet = false
                },
                isVacationTask: isSelectedTaskVacation(),
                isPresented: $showTaskEditSheet
            )
            .onAppear {
                print("🟡 TaskEdit sheet appeared")
            }
            .onDisappear {
                print("🟡 TaskEdit sheet disappeared")
                // 🔥 Store 상태도 동기화
                Task { @MainActor in
                    store.updateState { state in
                        state.showTaskEditSheet = false
                        state.selectedTaskIndex = nil
                    }
                }
            }
        }
        .onChange(of: store.state.showTaskEditSheet) { _, newValue in
            print("🟢 Store showTaskEditSheet changed to: \(newValue)")
            if newValue != showTaskEditSheet {
                showTaskEditSheet = newValue
            }
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
                    print("🔵 Navigation bar date tapped - showing DatePicker sheet")
                    showDatePickerSheet = true
                },
                onToggleChanged: { toggle in
                    store.send(.toggleChanged(toggle))
                }
            )
            
            CalendarSection(
                selectedDate: store.state.selectedDate,
                selectedToggle: store.state.selectedToggle,
                onDateTap: { date in
                    print("🟢 Calendar cell tapped: \(date) - direct date selection")
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
                                store.updateState { state in
                                    state.selectedTaskIndex = newValue
                                    if newValue != nil {
                                        print("🟡 Task selected at index: \(newValue!) - showing TaskEdit sheet")
                                        state.showTaskEditSheet = true
                                    }
                                }
                            }
                        }
                    ),
                    showTaskEditSheet: Binding(
                        get: { showTaskEditSheet },
                        set: { newValue in
                            print("🟡 TodoScrollSection trying to set showTaskEditSheet to: \(newValue)")
                            showTaskEditSheet = newValue
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

// MARK: - Helper Methods
private extension CalendarView {
    func isSelectedTaskVacation() -> Bool {
        guard let selectedIndex = store.state.selectedTaskIndex,
              selectedIndex < store.state.todoItems.count else {
            return false
        }
        
        return store.state.todoItems[selectedIndex].category?.name == "연차"
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
            
        case .showError(let message):
            print("❌ Error: \(message)")
            
        case .showSuccess(let message):
            print("✅ Success: \(message)")
        }
    }
}
