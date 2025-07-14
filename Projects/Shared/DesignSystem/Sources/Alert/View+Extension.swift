//
//  View+Extension.swift
//  DesignSystem
//
//  Created by SiJongKim on 7/14/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI

public extension View {
    func iOSAlert(
        config: iOSAlertConfig,
        isPresented: Binding<Bool>
    ) -> some View {
        self.alert(
            config.title,
            isPresented: isPresented
        ) {
            ForEach(0..<config.buttons.count, id: \.self) { index in
                let button = config.buttons[index]
                Button(button.title, role: button.role?.toSwiftUIRole) {
                    button.action()
                }
            }
        } message: {
            if let message = config.message {
                Text(message)
            }
        }
    }
    
    // 로그아웃 알럿
    func logoutAlert(
        isPresented: Binding<Bool>,
        onConfirm: @escaping () -> Void
    ) -> some View {
        self.iOSAlert(
            config: .logout(onConfirm: onConfirm),
            isPresented: isPresented
        )
    }
    
    // 회원탈퇴 알럿
    func withdrawalAlert(
        isPresented: Binding<Bool>,
        onConfirm: @escaping () -> Void
    ) -> some View {
        self.iOSAlert(
            config: .withdrawal(onConfirm: onConfirm),
            isPresented: isPresented
        )
    }
    
    // 확인 알럿
    func confirmationAlert(
        title: String,
        message: String? = nil,
        confirmTitle: String = "확인",
        cancelTitle: String = "취소",
        isPresented: Binding<Bool>,
        onConfirm: @escaping () -> Void
    ) -> some View {
        self.iOSAlert(
            config: .confirmation(
                title: title,
                message: message,
                confirmTitle: confirmTitle,
                cancelTitle: cancelTitle,
                onConfirm: onConfirm
            ),
            isPresented: isPresented
        )
    }
    
    // 알림 알럿 (확인 버튼만)
    func notificationAlert(
        title: String,
        message: String? = nil,
        buttonTitle: String = "확인",
        isPresented: Binding<Bool>,
        onConfirm: @escaping () -> Void = {}
    ) -> some View {
        self.iOSAlert(
            config: .notification(
                title: title,
                message: message,
                buttonTitle: buttonTitle,
                onConfirm: onConfirm
            ),
            isPresented: isPresented
        )
    }
    
    // 삭제 확인 알럿
    func deleteAlert(
        itemName: String,
        isPresented: Binding<Bool>,
        onConfirm: @escaping () -> Void
    ) -> some View {
        self.iOSAlert(
            config: .delete(itemName: itemName, onConfirm: onConfirm),
            isPresented: isPresented
        )
    }
}

// MARK: - Helper Extension

private extension iOSAlertButton.ButtonRole {
    var toSwiftUIRole: ButtonRole {
        switch self {
        case .destructive:
            return .destructive
        case .cancel:
            return .cancel
        }
    }
}
