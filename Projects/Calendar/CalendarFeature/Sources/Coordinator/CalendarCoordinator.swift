//
//  CalendarCoordinator.swift
//  CalendarFeature
//
//  Created by 이지훈 on 7/3/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Combine
import Coordinator
import SwiftUI

public final class CalendarCoordinator: ObservableObject, Coordinatorable {
    public typealias Screen = CalendarRouter.Screen
    public typealias SheetScreen = CalendarRouter.Sheet
    public typealias FullScreen = CalendarRouter.FullScreen
    
    @Published public var path: NavigationPath = NavigationPath()
    @Published public var sheet: SheetScreen?
    @Published public var fullScreenCover: FullScreen?
    
    public init() {
        print("🧭 CalendarCoordinator 생성")
    }
    
    @ViewBuilder
    public func view(_ screen: Screen) -> some View {
        switch screen {
        case .main:
            CalendarView()
        case .taskCreate:
            TaskCreateView()
        }
    }
    
    @ViewBuilder
    public func presentView(_ sheet: SheetScreen) -> some View {
        switch sheet {
        case .createEvent:
            CreateCalendarEventView()
        }
    }
    
    @ViewBuilder
    public func fullCoverView(_ cover: FullScreen) -> some View {
        switch cover {
        case .eventImport:
            EventImportView()
        }
    }
}

public enum CalendarRouter {
    public enum Screen: Hashable {
        case main
        case taskCreate
    }
    
    public enum Sheet: String, Identifiable {
        case createEvent
        public var id: String { self.rawValue }
    }
    
    public enum FullScreen: String, Identifiable {
        case eventImport
        public var id: String { self.rawValue }
    }
}

struct CreateCalendarEventView: View {
    @EnvironmentObject var coordinator: CalendarCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Text("➕ 새 이벤트 생성")
                .font(.largeTitle)
                .bold()
            
            Text("이벤트 생성 폼이 들어갑니다.")
                .foregroundColor(.secondary)
            
            Button("저장") {
                coordinator.dismissSheet()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .navigationTitle("새 이벤트")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EventImportView: View {
    @EnvironmentObject var coordinator: CalendarCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Text("📥 이벤트 가져오기")
                .font(.largeTitle)
                .bold()
            
            Text("외부 캘린더에서 이벤트를 가져옵니다.")
                .foregroundColor(.secondary)
            
            Button("완료") {
                coordinator.dismissCover()
            }
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}
