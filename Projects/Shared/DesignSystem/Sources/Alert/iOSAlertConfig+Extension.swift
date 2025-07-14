//
//  iOSAlertConfig+Extension.swift
//  DesignSystem
//
//  Created by SiJongKim on 7/14/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation

public extension iOSAlertConfig {
    static func logout(onConfirm: @escaping () -> Void) -> iOSAlertConfig {
        iOSAlertConfig(
            title: "로그아웃 하시나요?",
            buttons: [
                iOSAlertButton(title: "취소", role: .cancel),
                iOSAlertButton(title: "로그아웃", role: .destructive, action: onConfirm)
            ]
        )
    }
    
    static func withdrawal(onConfirm: @escaping () -> Void) -> iOSAlertConfig {
        iOSAlertConfig(
            title: "정말로 탈퇴 하시나요?",
            message: "지금까지의 모든 데이터가 사라지고 계정이 완전히 기록에서 삭제됩니다.",
            buttons: [
                iOSAlertButton(title: "취소", role: .cancel),
                iOSAlertButton(title: "계정 삭제", role: .destructive, action: onConfirm)
            ]
        )
    }
    
    static func confirmation(
        title: String,
        message: String? = nil,
        confirmTitle: String = "확인",
        cancelTitle: String = "취소",
        onConfirm: @escaping () -> Void
    ) -> iOSAlertConfig {
        iOSAlertConfig(
            title: title,
            message: message,
            buttons: [
                iOSAlertButton(title: cancelTitle, role: .cancel),
                iOSAlertButton(title: confirmTitle, action: onConfirm)
            ]
        )
    }
    
    static func notification(
        title: String,
        message: String? = nil,
        buttonTitle: String = "확인",
        onConfirm: @escaping () -> Void = {}
    ) -> iOSAlertConfig {
        iOSAlertConfig(
            title: title,
            message: message,
            buttons: [
                iOSAlertButton(title: buttonTitle, action: onConfirm)
            ]
        )
    }
    
    static func delete(
        itemName: String,
        onConfirm: @escaping () -> Void
    ) -> iOSAlertConfig {
        iOSAlertConfig(
            title: "\(itemName)을(를) 삭제하시겠습니까?",
            message: "삭제된 내용은 복구할 수 없습니다.",
            buttons: [
                iOSAlertButton(title: "취소", role: .cancel),
                iOSAlertButton(title: "삭제", role: .destructive, action: onConfirm)
            ]
        )
    }
}
