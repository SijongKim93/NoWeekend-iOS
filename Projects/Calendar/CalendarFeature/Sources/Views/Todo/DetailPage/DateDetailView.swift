//
//  DateDetailView.swift
//  CalendarFeature
//
//  Created by 이지훈 on 7/13/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import CalendarDomain
import DesignSystem
import DIContainer
import SwiftUI
import Utils

public struct DateDetailView: View {
    @EnvironmentObject private var coordinator: CalendarCoordinator
    
    let selectedDate: Date
    let calendarUseCase: CalendarUseCaseProtocol?
    
    @State private var schedules: [Schedule] = []
    @State private var todoItems: [DesignSystem.TodoItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedTaskIndex: Int?
    @State private var showTaskEditSheet = false
    @State private var editingTaskIndex: Int?
    @State private var showCategorySelection = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter
    }()
    
    public init(selectedDate: Date, calendarUseCase: CalendarUseCaseProtocol? = nil) {
        self.selectedDate = selectedDate
        self.calendarUseCase = calendarUseCase
    }
    
    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                navigationBar
                
                if isLoading {
                    VStack {
                        ProgressView("일정을 불러오는 중...")
                            .padding()
                        Spacer()
                    }
                } else if let errorMessage = errorMessage {
                    VStack {
                        Text("오류: \(errorMessage)")
                            .foregroundColor(.red)
                            .padding()
                        Spacer()
                    }
                } else {
                    contentView
                }
            }
            .background(DS.Colors.Background.normal)
            
            overlayContent
            floatingButton
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showTaskEditSheet) {
            TaskEditBottomSheet(
                onEditAction: handleTaskEdit,
                onTomorrowAction: handleTomorrowAction,
                onDeleteAction: handleDeleteAction,
                isVacationTask: isSelectedTaskVacation(),
                isPresented: $showTaskEditSheet
            )
        }
        .task {
            await loadSchedules()
        }
    }
    
    private var navigationBar: some View {
        CustomNavigationBar(
            type: .backWithLabel(dateFormatter.string(from: selectedDate)),
            onBackTapped: {
                coordinator.pop()
            }
        )
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 열정 온도 카드
                temperatureCard
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // 온도 바
                temperatureBar
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                
                // 할 일 섹션
                todoSection
                    .padding(.top, 24)
                
                Spacer(minLength: 100)
            }
        }
    }
    
    private var temperatureCard: some View {
        ZStack {
            // 빵 이미지를 전체 배경으로 사용
            temperatureImage(averageTemperature)
                .resizable()
                .scaledToFill()
                .clipped()
            
            // 텍스트 컨텐츠
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("오늘의 열정 온도")
                        .font(.heading5)
                        .foregroundColor(DS.Colors.Neutral.black)
                    
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("\(averageTemperature)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(DS.Colors.TaskItem.orange)
                        
                        Text("°C")
                            .font(.heading4)
                            .foregroundColor(DS.Colors.TaskItem.orange)
                            .padding(.bottom, 8)
                    }
                }
                
                Spacer()
            }
            .padding(20)
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var temperatureBar: some View {
        VStack(spacing: 8) {
            // 온도 바
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 배경 바
                    RoundedRectangle(cornerRadius: 8)
                        .fill(DS.Colors.Neutral.gray200)
                        .frame(height: 8)
                    
                    // 진행 바
                    RoundedRectangle(cornerRadius: 8)
                        .fill(temperatureBarGradient)
                        .frame(width: geometry.size.width * CGFloat(averageTemperature) / 100, height: 8)
                }
            }
            .frame(height: 8)
            
            // 온도 라벨
            HStack {
                Text("0°C")
                    .font(.body3)
                    .foregroundColor(DS.Colors.Text.disable)
                
                Spacer()
                
                Text("25°C")
                    .font(.body3)
                    .foregroundColor(DS.Colors.Text.disable)
                
                Spacer()
                
                Text("50°C")
                    .font(.body3)
                    .foregroundColor(DS.Colors.Text.disable)
                
                Spacer()
                
                Text("100°C")
                    .font(.body3)
                    .foregroundColor(DS.Colors.Text.disable)
            }
        }
    }
    
    private var todoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 할 일 헤더
            HStack {
                HStack(spacing: 0) {
                    Text("할 일 ")
                        .font(.heading5)
                        .foregroundStyle(DS.Colors.Text.netural)
                    
                    Text("\(incompleteTodoCount)")
                        .font(.heading5)
                        .foregroundStyle(DS.Colors.Text.netural)
                    
                    Text(" / ")
                        .font(.heading5)
                        .foregroundStyle(DS.Colors.Text.disable)
                    
                    Text("\(todoItems.count)")
                        .font(.heading5)
                        .foregroundStyle(DS.Colors.Text.disable)
                    
                    Text("개")
                        .font(.heading5)
                        .foregroundStyle(DS.Colors.Text.netural)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            // 할 일 목록
            if todoItems.isEmpty {
                VStack(spacing: 16) {
                    DS.Images.imgFlour
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                    
                    Text("이 날의 할 일이 없습니다")
                        .font(.body1)
                        .foregroundColor(DS.Colors.Text.disable)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(todoItems.enumerated()), id: \.element.id) { index, todo in
                        TodoCheckboxComponent(
                            todoItem: todo,
                            onToggle: {
                                todoItems[index].isCompleted.toggle()
                            },
                            onMoreTapped: {
                                selectedTaskIndex = index
                                showTaskEditSheet = true
                            }
                        )
                        .contentShape(Rectangle())
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var overlayContent: some View {
        if showCategorySelection {
            TaskCategorySelectionView(
                isPresented: $showCategorySelection,
                onCategorySelected: handleCategorySelection,
                onDirectInputTapped: handleDirectInput
            )
            .zIndex(1)
        }
    }
    
    private var floatingButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                FloatingAddButton(
                    isExpanded: true,
                    isShowingCategory: showCategorySelection,
                    action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showCategorySelection = true
                        }
                    },
                    dismissAction: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showCategorySelection = false
                        }
                    }
                )
                .padding(.trailing, 20)
                .padding(.bottom, 33)
            }
        }
        .zIndex(4)
    }
}

// MARK: - Computed Properties
private extension DateDetailView {
    var averageTemperature: Int {
        guard !schedules.isEmpty else { return 50 } // Mock data용으로 50도 기본값
        let totalTemperature = schedules.reduce(0) { $0 + $1.temperature }
        return totalTemperature / schedules.count
    }
    
    var incompleteTodoCount: Int {
        todoItems.filter { !$0.isCompleted }.count
    }
    
    var temperatureBarGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.8, green: 0.9, blue: 1.0),
                Color(red: 1.0, green: 0.7, blue: 0.4),
                Color(red: 1.0, green: 0.5, blue: 0.2)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    func temperatureImage(_ temperature: Int) -> Image {
        switch temperature {
        case 0...20: return DS.Images.imgPlaneBread
        case 21...40: return DS.Images.imgHotbread
        case 41...60: return DS.Images.imgGridenteBread
        case 61...80: return DS.Images.imgBurnBread
        case 81...100: return DS.Images.imgBurnBread
        default: return DS.Images.imgHotbread
        }
    }
    
    func isSelectedTaskVacation() -> Bool {
        guard let selectedIndex = selectedTaskIndex,
              selectedIndex < todoItems.count else {
            return false
        }
        
        return todoItems[selectedIndex].category?.name == "연차"
    }
}

// MARK: - Event Handlers
private extension DateDetailView {
    func handleTaskEdit() {
        showTaskEditSheet = false
        if let index = selectedTaskIndex {
            editingTaskIndex = index
        }
    }
    
    func handleTomorrowAction() {
        showTaskEditSheet = false
        // TODO: 내일 또 하기 로직 구현
    }
    
    func handleDeleteAction() {
        showTaskEditSheet = false
        if let index = selectedTaskIndex {
            todoItems.remove(at: index)
            selectedTaskIndex = nil
        }
    }
    
    func handleCategorySelection(_ category: TaskCategory) {
        let newTodo = DesignSystem.TodoItem(
            id: todoItems.count + 1,
            title: category.name,
            isCompleted: false,
            category: DesignSystem.TodoCategory(name: category.name, color: category.color),
            time: nil,
            scheduleId: nil
        )
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            todoItems.append(newTodo)
        }
        
        editingTaskIndex = todoItems.count - 1
        showCategorySelection = false
    }
    
    func handleDirectInput() {
        showCategorySelection = false
        coordinator.push(.taskCreate(selectedDate: selectedDate))
    }
}

// MARK: - Data Loading
private extension DateDetailView {
    func loadSchedules() async {
        // 프리뷰나 UseCase가 없는 경우 Mock 데이터 사용
        guard let useCase = calendarUseCase ?? DIContainer.shared.container.resolve(CalendarUseCaseProtocol.self) else {
            await loadMockData()
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let dateString = selectedDate.toString(format: "yyyy-MM-dd")
            print("🗓️ 날짜 디테일 로딩 - 선택된 날짜: \(dateString)")
            
            let dailySchedules = try await useCase.getSchedulesForDateRange(
                startDate: selectedDate,
                endDate: selectedDate
            )
            
            print("📋 API로부터 받은 일정 수: \(dailySchedules.count)")
            
            if let daySchedule = dailySchedules.first(where: { $0.date == dateString }) {
                let schedulesForDay = daySchedule.schedules
                print("📅 \(dateString)의 일정: \(schedulesForDay.count)개")
                
                for (index, schedule) in schedulesForDay.enumerated() {
                    print("📌 일정 \(index + 1): ID=\(schedule.id), 제목=\(schedule.title), 카테고리=\(schedule.category.displayName)")
                }
                
                await MainActor.run {
                    self.schedules = schedulesForDay
                    self.todoItems = self.createTodoItemsFromSchedules(schedulesForDay)
                    self.isLoading = false
                }
            } else {
                print("❌ \(dateString)에 해당하는 일정을 찾을 수 없습니다")
                await MainActor.run {
                    self.schedules = []
                    self.todoItems = []
                    self.isLoading = false
                }
            }
            
        } catch {
            print("❌ 일정 로딩 실패: \(error.localizedDescription)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func loadMockData() async {
        await MainActor.run {
            self.schedules = mockSchedules
            self.todoItems = mockTodoItems
            self.isLoading = false
        }
    }
    
    var mockSchedules: [Schedule] {
        [
            Schedule(
                id: "1",
                title: "길게 들어가면 이렇게 보여집니다. 길게 들어...",
                startTime: Date(),
                endTime: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date(),
                category: .company,
                temperature: 50,
                allDay: false,
                alarmOption: .none,
                completed: false
            ),
            Schedule(
                id: "2",
                title: "할 일 제목이 들어갑니다.",
                startTime: Date(),
                endTime: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date(),
                category: .personal,
                temperature: 60,
                allDay: false,
                alarmOption: .none,
                completed: true
            )
        ]
    }
    
    var mockTodoItems: [DesignSystem.TodoItem] {
        [
            DesignSystem.TodoItem(
                id: 1,
                title: "길게 들어가면 이렇게 보여집니다. 길게 들어...",
                isCompleted: false,
                category: DesignSystem.TodoCategory(name: "회사", color: DS.Colors.TaskItem.green),
                time: "오전 10:00",
                scheduleId: "1"
            ),
            DesignSystem.TodoItem(
                id: 2,
                title: "할 일 제목이 들어갑니다.",
                isCompleted: false,
                category: DesignSystem.TodoCategory(name: "개인", color: DS.Colors.TaskItem.orange),
                time: "오전 10:00",
                scheduleId: "2"
            ),
            DesignSystem.TodoItem(
                id: 3,
                title: "할 일 제목이 들어갑니다.",
                isCompleted: true,
                category: DesignSystem.TodoCategory(name: "개인", color: DS.Colors.TaskItem.orange),
                time: "오전 10:00",
                scheduleId: "3"
            )
        ]
    }
    
    func createTodoItemsFromSchedules(_ schedules: [Schedule]) -> [DesignSystem.TodoItem] {
        return schedules.enumerated().map { index, schedule in
            let category = DesignSystem.TodoCategory(
                name: schedule.category.displayName,
                color: schedule.category.designSystemColor
            )
            
            return DesignSystem.TodoItem(
                id: index + 1,
                title: schedule.title,
                isCompleted: schedule.completed,
                category: category,
                time: schedule.allDay ? "하루 종일" : schedule.startTime.toString(format: "a h:mm"),
                scheduleId: schedule.id
            )
        }
    }
}
