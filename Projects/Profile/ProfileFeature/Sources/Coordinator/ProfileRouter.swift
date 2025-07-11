//
//  ProfileRouter.swift
//  ProfileFeature
//
//  Created by SiJongKim on 7/11/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import SwiftUI

public enum ProfileRouter {
    public enum Screen: Hashable {
        case home
        case edit
        case infoEdit
        case tags
        case vacation
    }
    
    public enum Sheet: RawRepresentable, Identifiable {
        case tagResult(selectedTags: [String])
        case category(currentCategory: String)
        
        public var id: String {
            switch self {
            case .tagResult:
                return "tagResult"
            case .category:
                return "category"
            }
        }
        
        public var rawValue: String {
            return id
        }
        
        public init?(rawValue: String) {
            switch rawValue {
            case "tagResult":
                self = .tagResult(selectedTags: [])
            case "category":
                self = .category(currentCategory: "")
            default:
                return nil
            }
        }
    }
    
    public enum FullScreen: RawRepresentable, Identifiable {
        case webView(URL)
        
        public var id: String {
            switch self {
            case .webView(let url):
                return "webView_\(url.absoluteString)"
            }
        }
        
        // RawRepresentable 준수
        public var rawValue: String {
            return id
        }
        
        public init?(rawValue: String) {
            if rawValue.hasPrefix("webView_"),
               let urlString = String(rawValue.dropFirst("webView_".count)).removingPercentEncoding,
               let url = URL(string: urlString) {
                self = .webView(url)
            } else {
                return nil
            }
        }
    }
}
