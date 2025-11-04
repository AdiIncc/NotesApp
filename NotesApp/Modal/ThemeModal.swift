//
//  ThemeModal.swift
//  NotesApp
//
//  Created by Adrian Inculet on 02.11.2025.
//

import Foundation
import UIKit

enum AppTheme: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
        var displayName: String {
            switch self {
            case .system:
                return "System"
            case .light:
                return "Light"
            case .dark:
                return "Dark"
            }
        }
        
        var systemIcon: String {
            switch self {
            case .system:
                return "display"
            case .light:
                return "sun.max.fill"
            case .dark:
                return "moon.fill"
            }
        }
    }

extension Notification.Name {
    static let appThemeChanged = Notification.Name("appThemeChanged")
}

final class ThemeManager {
    static let shared = ThemeManager()
    private let userDefaultsKey = "appTheme"
    private init() {}
    
    var current: AppTheme {
        get {
            AppTheme(rawValue: UserDefaults.standard.integer(forKey: userDefaultsKey)) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: userDefaultsKey)
            apply(newValue)
            NotificationCenter.default.post(name: .appThemeChanged, object: nil)
        }
    }
    
    func apply(_ theme: AppTheme? = nil) {
        let themeToApply = theme ?? current
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.forEach { scene in
            scene.windows.forEach { $0.overrideUserInterfaceStyle = themeToApply.userInterfaceStyle }
        }
    }
}
