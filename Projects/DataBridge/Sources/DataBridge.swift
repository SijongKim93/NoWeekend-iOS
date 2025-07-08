//
//  DataBridge.swift
//  DataBridge
//
//  Created by 이지훈 on 7/3/25.
//

import CalendarData
import DIContainer
import Foundation
import HomeData
import LoginData
import OnboardingData
import ProfileData
import Utils

// DataBridge는 모든 Data 모듈들을 한곳에 모아주는 역할
public enum DataBridge {
    public static func initialize() {
        print("🌉 DataBridge 초기화 시작")
        
        let utilsAssembly = UtillsAssembly()
        DIContainer.shared.registerAssembly(assembly: [utilsAssembly])
        
        LoginDataModule.registerRepositories()
        
        HomeDataModule.registerRepositories()
        ProfileDataModule.registerRepositories()
        CalendarDataModule.registerRepositories()
        OnboardingDataModule.registerRepositories()
        LoginDataModule.registerRepositories()

        print("✅ DataBridge 초기화 완료")
    }
}
