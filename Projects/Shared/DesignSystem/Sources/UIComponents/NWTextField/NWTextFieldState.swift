//
//  NWTextFieldState.swift
//  DesignSystem
//
//  Created by 김시종 on 6/19/25.
//

import SwiftUI

public enum NWTextFieldState {
    case normal
    case typing
    case typingError
    
    public var borderColor: Color {
        switch self {
        case .normal:
            return DS.Colors.Border.border02
        case .typing:
            return DS.Colors.Neutral.black
        case .typingError:
            return DS.Colors.Toast._700
        }
    }
    
    public var borderWidth: CGFloat {
        switch self {
        case .normal, .typingError:
            return 1
        case .typing:
            return 2
        }
    }
}
